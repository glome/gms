module Gms
  class Account < ActiveRecord::Base
    attr_accessible :glomeid, :domain
    attr_accessor :glomeid, :password

    validates :name, :uniqueness => { :case_sensitive => false }
    validates :domain, :presence => true
    validates :user_id, :presence => true

    belongs_to :user, class_name: "User"

    before_save :preset
    # TODO: not yet working; get sidekiq workers working in modules
    # actually call the lib/gms/xmpp.rb lib create method from this
    #after_save :register_jabber

    private

    def preset
      self.user = User.find_by_glomeid(glomeid)

      if not name.present?
        found = true
        until not found
          self.name = SecureRandom.hex(8)
          found = Account.where(name: self.name).take
        end
        self.password = self.name
      end
    end

    def register_jabber
      struct = {
        :name => self.name,
        :alias => self.alias,
        :resource => self.resource,
        :domain => self.domain,
        :password => self.password
      }
      logger.debug 'Call EjabberdRegister async: ' + struct.inspect
      EjabberdRegister.perform_async(struct)
    end
  end
end
