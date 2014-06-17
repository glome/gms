#:nodoc:all
#
# Send a simple XMPP message to a preconfigured XMPP server / chat room
#

class EjabberdChatRoom
  include Sidekiq::Worker

  sidekiq_options :retry => 1

  def perform muc, msg
    puts 'try to perform'
    Rails.logger.info 'Gms::EjabberdChatRoom perform'

    muc.send(msg)
    Rails.logger.error 'Sent XMPP message: ' + msg.inspect
    muc = msg = nil

    #begin
    #Rails.logger.info 'Gms::EjabberdChatRoom perform'
    #Gms::Xmpp.send_message type, message

    #rescue => e
    #  Rails.logger.error 'ERROR: Gms::EjabberdChatRoom: failed to send message. Error: ' + e.inspect
    #end
  end
end
