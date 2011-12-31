require "em-mailer/version"
require "em-mailer/client"

if Rails::VERSION::MAJOR == 2
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
        em_client = Em::Mailer.new(em_mailer_settings)
        em_client.deliver!(mail)
      end
    end
  end
else
  ActionMailer::Base.add_delivery_method :em_mailer, Em::Mailer::Client
end
