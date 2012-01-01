require "action_mailer"
require "em-mailer/version"
require "em-mailer/client"

if defined?(Rails) && Rails::VERSION::MAJOR == 2
  module ActionMailer
    class Base
      @@em_mailer_settings = {
        :host             => 'localhost',
        :port             => 5600,
        :delivery_method  => :sendmail,
        :delivery_options => {}
      }
      cattr_accessor :em_mailer_settings

      def perform_delivery_em_mailer(mail)
        em_client = Em::Mailer::Client.new(em_mailer_settings)
        em_client.deliver!(mail)
      end
    end
  end
else
  ActionMailer::Base.add_delivery_method :em_mailer, Em::Mailer::Client
end

