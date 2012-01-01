em-mailer
=========
EM-Mailer is an asynchronous delivery implementation for ActionMailer
that includes a mail client for your ActionMailer message deliveries
and an eventmachine-based server-side process.

Delivering large numbers of e-mail messages synchronously is an
exercise in disaster. And yes, there are lots of other implementations
for asynchronous message delivery (ar_mailer, background job submission
via a number of queue-based implementations, incl. MailHopper).

I personally wanted a lightweight daemon to do this for me, and didn't
want to have to use my database or configure Resque or DelayedJob to
handle these mass deliveries.

Enter eventmachine and em-mailer.

Installation
------------
Getting em-mailer installed is straightforward. In your Gemfile:

    gem 'em_mailer'

Configuration
-------------
You must let ActionMailer know that you wish to use em-mailer as your
delivery method. Either in your application's config/application.rb
file (assuming Rails 3), or in an environment-specific config file
such as config/environments/production.rb:

    config.action_mailer.delivery_method = :em_mailer

Presuming you are sending e-mails via :sendmail that's all that is
required for getting your Rails application configured.

If you want to use a different delivery method, or if you require
additional delivery options, use the em_mailer_settings class
attribute values.

For example, if you wish to use SMTP you can do something like this:

In config/initializers/em_mailer.rb

    ActionMailer::Base.em_mailer_settings[:delivery_method] = :smtp
    ActionMailer::Base.em_mailer_settings[:delivery_options] = {
      :address => '<< your smtp server name>>',
      :port => 25,
      :domain => '<< your domain >>',
      :authentication => :plain,
      :user_name => '<< user with access to smtp host >>',
      :password => '<< their password >>'
    }

Rails Support
-------------
I have tested this with both a Rails 3.1 and Rails 2.x applications.

Running the Mail Server
-----------------------
You'll need a running instance of the mail server running. The gem
comes bundled with a binary called em_mailer_server. You can run it
from the command line thusly:

    em_mailer_server

To run it daemonized it's as easy as:

    em_mailer_server -D

You can also specify the port that you want the server to listen on
(default is 5600)

    em_mailer_server -p 5600 -D

For a full list of configuration options pass it a -h, or --help.

Start/Stop Script
-----------------
I happen to be running em_mailer_server on a CentOS box. Here's my
/etc/init.d/em_mailer script that I use to start|stop|restart the
process on that host:

    #!/bin/bash
    #
    # EM Mailer
    #
    # chkconfig: - 85 15
    # description: start, stop, restart EM Mailer Server
    #
    RETVAL=0

    case "$1" in
        start)
          /usr/local/bin/em_mailer_server -P /var/run/em_mailer.pid -D
          RETVAL=$?
      ;;
        stop)
          kill `cat /var/run/em_mailer.pid`
          RETVAL=$?
      ;;
        restart)
          kill `cat /var/run/em_mailer.pid`
          /usr/local/bin/em_mailer_server -P /var/run/em_mailer.pid -D
          RETVAL=$?
      ;;
        *)
          echo "Usage: em_mailer {start|stop|restart}"
          exit 1
      ;;
    esac
 
    exit $RETVAL

Monitoring
----------
Lastly, I like to use monit to make sure my daemon processes are up and
running. Here's my sample monit script:

    check process em_mailer with pidfile /var/run/em_mailer.pid
      start program = "/etc/init.d/em_mailer start"
      stop program = "/etc/init.d/em_mailer stop"
      if failed port 5600 then restart
      group mail

