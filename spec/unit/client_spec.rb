require 'spec_helper'

describe Em::Mailer::Client do
  describe "#initialize" do
    before do
      @client = Em::Mailer::Client.new({})
    end

    it "default's host to localhost" do
      @client.settings[:host].should == 'localhost'
    end

    it "default's port to 5600" do
      @client.settings[:port].should == 5600
    end

    it "default's delivery method to :sendmail" do
      @client.settings[:delivery_method].should == :sendmail
    end

    it "default's delivery options to an empty hash" do
      @client.settings[:delivery_options].should == {}
    end

    it "allows overridding the port" do
      @client = Em::Mailer::Client.new({:port => 5700})
      @client.settings[:port].should == 5700
    end

    it "allows overridding the delivery method" do
      @client = Em::Mailer::Client.new({:delivery_method => :smtp})
      @client.settings[:delivery_method].should == :smtp
    end

    it "allows overridding the delivery options" do
      @client = Em::Mailer::Client.new({:delivery_options => {:username => 'meh'}})
      @client.settings[:delivery_options][:username].should == 'meh'
    end
  end

  describe "#deliver!" do
    before do
      @mail = { :to => 'bleh@foo.com', :subject => 'Hai!' }
      @socket = mock(TCPSocket, :close => true)
      @client = Em::Mailer::Client.new({:host => 'foo', :port => 42})
      @client.stub(:open_socket).and_return(@socket)
    end

    it "opens a socket" do
      @client.should_receive(:open_socket)
      @client.deliver!(@mail)
    end

    it "encodes a hash, along with the socket" do
      Yajl::Encoder.should_receive(:encode).with(an_instance_of(Hash),@socket)
      @client.deliver!(@mail)
    end

    it "converts the mail message to a String" do
      @mail.should_receive(:to_s)
      @client.deliver!(@mail)
    end

    it "closes the socket" do
      @socket.should_receive(:close)
      @client.deliver!(@mail)
    end
  end

  describe "#open_socket" do
    it "instantiates a socket on the correct host and port" do
      @client = Em::Mailer::Client.new({:host => 'foo', :port => 42})
      TCPSocket.should_receive(:new).with('foo',42)
      @client.open_socket
    end
  end
end

