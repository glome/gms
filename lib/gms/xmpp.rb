#:nodoc:all
require 'yaml'
require 'xmpp4r'
require 'xmpp4r/muc'
require 'xmpp4r/roster'
require 'xmpp4r/client'
require 'xmpp4r/pubsub'
require 'xmpp4r/stream'

module Gms
  class Xmpp
    attr_accessor :configuration, :rooms, :adminclient

    #
    #
    #
    def logger severity='info', message
      code = 'Gms:Xmpp'

      case severity
      when 'debug'
        Rails.logger.debug 'DEBUG: ' + code + ': ' + message
      when 'info'
        Rails.logger.debug 'INFO: ' + code + ': ' + message
      when 'error'
        Rails.logger.debug 'ERROR: ' + code + ': ' + message
      end
    end

    #
    # initialize configuration
    #
    def init configfile
      begin
        @configuration = YAML.load_file(configfile)
        self.logger 'info', 'Parsed configuration: ' + @configuration.inspect
      rescue => e
        self.logger 'error', 'Failed to initialize configuration: ' + e.inspect
      end
    end

    #
    # This method should be called asynchronously (from a sidekiq worker).
    #
    def connect username = nil, password = nil, room = nil
      username = @configuration['credentials']['username'] if username.nil?
      password = @configuration['credentials']['password'] if password.nil?

      if not @configuration['enabled']
        self.logger 'info', 'XMPP connection disabled by configuration'
        return
      end

      fullname = username + '@' + @configuration['server']
      fulljid = Jabber::JID::new(fullname)

      close = false
      client = Jabber::Client::new(fulljid)

      begin
        client.connect
      rescue
        # try local
        client.connect 'localhost'
      end

      self.logger 'info', fullname + ' connected'

      # just wait a bit
      sleep 2

      begin
        client.register password
      rescue Jabber::ServerError => e
        begin
          self.logger 'debug', 'Trying XMPP auth: ' + fullname
          client.auth password
        rescue Jabber::ClientAuthenticationFailure => e
          self.logger 'error', 'Could not authenticate ' + fullname + ': ' + e.inspect
          close = true
        end
      end

      if close
        self.logger 'debug', 'Closing XMPP connection: ' + fullname
        client.close
      else
        self.logger 'debug', @configuration['credentials']['username'] + ' vs ' + username

        @rooms = {}

        if @configuration['credentials']['username'] == username
          # connect the default user to all available rooms
          self.logger 'info', 'Connect ' + username + ' to all rooms'

          # this client can be used to send direct messages to users
          @admin_client = client

          @configuration['rooms'].each do |room, data|
            @rooms[room] = self.connect_room true, client, data['name'], data['password'] unless @rooms[room].present?
          end
        else
          # connect any other user
          self.connect_room false, client, room, password unless room.nil?
        end
      end
    end

    #
    # connects to a room and does some configuration
    #
    def connect_room default, client, room, password
      muc = Jabber::MUC::MUCClient.new client

      begin
        self.logger 'info', 'Trying connecting to room: ' + room
        roomjid = Jabber::JID::new(room + '@' + @configuration['conference_server'] + '/' + client.jid.node)
        muc.join roomjid, password

        self.logger 'debug', 'Joined room: ' + room
      rescue Jabber::ServerError => e
        self.logger 'error', 'Could not join room: ' + roomjid.inspect + ' on ' + @configuration['conference_server'] + ': ' + e.inspect
        muc = nil
      end

      if default and @rooms[room].nil?
        config = {
          'allow_query_users' => 0,
          'muc#roomconfig_persistentroom' => 0,
          'muc#roomconfig_publicroom' => (@configuration['rooms'][room]['public'] ? 1 : 0),
          'muc#roomconfig_membersonly' => (@configuration['rooms'][room]['members'] ? 1 : 0),
          'muc#roomconfig_roomdesc' => @configuration['rooms'][room]['description']
        }

        begin
          self.logger 'info', 'Trying configuring the room: ' + room
          muc.submit_room_configuration config
          self.logger 'debug', 'Configured room: ' + room
        rescue Jabber::ServerError => e
          self.logger 'error', 'Could not configure room: ' + roomjid.inspect + ' on ' + @configuration['conference_server'] + ': ' + e.inspect
          muc = nil
        end
      end

      muc
    end

    #
    # This method should be called asynchronously (from a sidekiq worker).
    #
    # The 'type' parameter matches the room name in the configuration.
    #
    def send_to_room type, message
      muc = @rooms[type]
      room = @configuration['rooms'][type]['name']

      if @configuration['enabled'] and muc
        msg = Jabber::Message::new(room, message)
        muc.send msg

        self.logger 'info', 'Sent XMPP message: ' + msg.inspect + ' to ' + room
        muc = msg = nil
      end
    end

    #
    # This method should be called asynchronously (from a sidekiq worker).
    #
    # The 'type' parameter matches the room name in the configuration.
    #
    def send_to_user username, message
      self.logger 'debug', 'try sending message: ' + message + ' to user: ' + username

      jid = Jabber::JID::new(username + '@' + @configuration['server'])

      if @configuration['enabled'] and @admin_client
        msg = Jabber::Message::new(jid, message)
        @admin_client.send msg

        self.logger 'info', 'Sent XMPP message: ' + msg.inspect + ' to ' + jid.to_s
        msg = nil
      end
    end
  end
end