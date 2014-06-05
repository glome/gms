module Gms
  class Account < ActiveRecord::Base
    #attr_accessible :glomeid, :user_id, :name, :password, :domain, :resource, :alias
    attr_accessor :glomeid, :password

    validates :name, :uniqueness => { :case_sensitive => false }

    belongs_to :user, class_name: "User"

    before_save :preset
    after_save :register_jabber

    private

    def preset
      self.user = User.find_by_glomeid(glomeid)

      if not name.present?
        found = true
        until not found
          self.name = SecureRandom.hex(8)
          self.password = self.name
          found = Account.where(name: self.name).take
        end
      end
    end

    def register_jabber
      struct = {
        :name => self.name,
        :alias => self.alias,
        :resource => self.resource,
        :domain => self.resource,
        :password => self.password
      }
      logger.debug 'Call EjabberdRegister async: ' + struct.inspect
      EjabberdRegister.perform_async(struct)
    end
  end
end
