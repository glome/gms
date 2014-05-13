module Gms
  class Account < ActiveRecord::Base
    attr_accessible :glomeid, :user_id, :name, :domain, :resource, :alias
    attr_accessor :glomeid

    belongs_to :user, class_name: "User"

    before_save :set_user

    private

    def set_user
      self.user = User.find_by_glomeid(glomeid)
    end
  end
end
