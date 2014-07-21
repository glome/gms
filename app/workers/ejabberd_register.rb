#:nodoc:all
#
# Calls ejabberd REST API to register an account
#
module Gms
  class EjabberdRegister
    include Sidekiq::Worker

    sidekiq_options :retry => 0, :backtrace => true

    def perform struct
      begin
        logger.info 'Call ejabberd HTTP REST API: ' + struct.inspect
      rescue => e
        logger.error 'Error registering ejabberd account'
        logger.error e.inspect
      end
    end
  end
end