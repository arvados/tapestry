#!/bin/bash

## This works on GNU/Linux
LSOF=$(lsof -p $$ | grep -E "/"$(basename "$0")"$")
MY_PATH=$(echo $LSOF | sed -r s/'^([^\/]+)\/'/'\/'/1 2>/dev/null)
P=$(dirname $MY_PATH)

RUBY="/usr/bin/env PATH=/usr/local/bin:$PATH ruby"
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

