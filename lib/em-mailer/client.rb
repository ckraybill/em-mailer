require 'socket'
require 'yajl'

module Em
  module Mailer
    class Client
      def initialize(values)
        self.settings = {
          :host             => 'localhost',
          :port             => 5600,
          :delivery_method  => :sendmail,
          :delivery_options => {}
        }.merge!(values)
      end

      attr_accessor :settings

      def deliver!(mail)
        socket = TCPSocket.new(settings[:host], settings[:port])
        Yajl::Encoder.encode({
          :message          => mail.to_s,
          :delivery_method  => settings[:delivery_method],
          :delivery_options => settings[:delivery_options]
        }, socket)
        socket.close
      end
    end
  end
end
