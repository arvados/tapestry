#!/bin/sh

RUBY=/usr/bin/env ruby
P=/path/to/your/drb/folder
SERVER=mypg_server.rb

case "$1" in
    start)
			echo "Starting mypg_server..."
			/usr/bin/daemon -u www-data -r -U -o $P/../log/mypg_server.error1 -E $P/../log/mypg_server.error -O $P/../log/mypg_server.log -n mypg_server_production $RUBY $P/$SERVER production
  ;;
    stop)
			echo "Stopping mypg_server..."
			/usr/bin/daemon -u www-data --stop -n mypg_server_production
  ;;
    restart)
			/usr/bin/daemon -u www-data --running -n mypg_server_production
			if [ "$?" = "0" ]; then
				echo "Restarting mypg_server..."
				/usr/bin/daemon -u www-data --restart -n mypg_server_production
			else
				echo "mypg_server was not running. Starting it now..."
				/usr/bin/daemon -u www-data -r -U -o $P/../log/mypg_server.error1 -E $P/../log/mypg_server.error -O $P/../log/mypg_server.log -n mypg_server_production $RUBY $P/$SERVER production
			fi
  ;;
  *)
  echo "Usage: $0 {start|stop|restart}" >&2
  exit 1
  ;;
esac

