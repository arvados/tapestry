#!/bin/sh

RUBY=/usr/local/bin/ruby
P=/data/personal/data/2010/projects/sequencing/PGP/pgp-enroll/drb
SERVER=mypg_server.rb
DELAY_BETWEEN_RESTART=5

#while : 
#do 
#	$RUBY $SERVER $1
#	echo "Sleeping $DELAY_BETWEEN_RESTART seconds before restart..."
#	sleep $DELAY_BETWEEN_RESTART
#done

case "$1" in
    start)
			echo "Starting mypg_server..."
			/usr/bin/daemon -r -U -o $P/../log/mypg_server.error1 -E $P/../log/mypg_server.error -O $P/../log/mypg_server.log -n mypg_server_dev $RUBY $P/$SERVER development
  ;;
    stop)
			echo "Stopping mypg_server..."
			/usr/bin/daemon --stop -n mypg_server_dev
  ;;
    restart)
			/usr/bin/daemon --running -n mypg_server_dev
			if [ "$?" = "0" ]; then
				echo "Restarting mypg_server..."
				/usr/bin/daemon --restart -n mypg_server_dev
			else
				echo "mypg_server was not running. Starting it now..."
				/usr/bin/daemon -r -U -o $P/../log/mypg_server.error1 -E $P/../log/mypg_server.error -O $P/../log/mypg_server.log -n mypg_server_dev $RUBY $P/SERVER development
			fi
  ;;
  *)
  echo "Usage: $0 {start|stop|restart}" >&2
  exit 1
  ;;
esac

