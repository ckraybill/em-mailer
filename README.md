#README

WARNING: This is an experiment.

You probably don't want to use this (quite yet). I haven't even begun
to see if it works on Rails 3. But, I can assure you it *is* working
in production for an old Rails 2 customer.

For those that have read the aforementioned caveats and are gluttons
for punishment, please read on.

##Why?
I wrote em-mailer to solve a problem that I was having. I wanted to
send e-mails (to a fair # of subscribers) asynchronously. I didn't
want to use Resque or another background job / worker solution for 
this, I wanted a drop-dead simple mail server process whose sole job
was to accept Mail messages encoded as JSON over a socket, and then 
deliver them according to the delivery options (I've tested both
:sendmail and :smtp configurations).

##Rails 2
I originally wrote em_mailer for an old Rails 2 app that I hadn't
bothered getting around to migrating, so there's built-in support
for similarly lazy-minded individuals.

In config/environment.rb:

    config.gem 'em_mailer'

In config/environments/production.rb

    config.action_mailer.delivery_method = :em_mailer

Out of the box it works with :sendmail delivery as the default.

If you wish to use SMTP you can do something like this:

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
    
##Rails 3
In your Gemfile

    gem 'em_mailer'

That should be all that's necessary. Again, haven't experimented (yet).

##Running the Mail Server
You'll need a running instance of the mail server running. The gem
comes bundled with a binary em_mailer_server. You can run it from
a command line thusly:

    em_mailer_server

To run it daemonized it's as easy as:

    em_mailer_server -D

You can also specify the port that you want the server to listen on
(default is 5600)

    em_mailer_server -p 5600 -D

For a full list of configuration options pass it a -h, or --help.

##Start/Stop Script
I happen to be running em_mailer_server on a CentOS box. Here's my
/etc/init.d/em_mailer script that I use to start|stop|restart the
process on the host server

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

##Monitoring
Lastly, I like to use monit to make sure my daemon processes are up and
running. Here's my sample monit script:

    check process em_mailer with pidfile /var/run/em_mailer.pid
      start program = "/etc/init.d/em_mailer start"
      stop program = "/etc/init.d/em_mailer stop"
      if failed port 5600 then restart
      group mail

