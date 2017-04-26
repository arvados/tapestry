#!/bin/bash

# Copyright (C) The Tapestry Authors. All rights reserved.
#
# SPDX-License-Identifier: AGPL-3.0

EXITCODE=0

COLUMNS=80

title () {
  printf "\n%*s\n\n" $(((${#title}+$COLUMNS)/2)) "********** $1 **********"
}

source $HOME/.rvm/scripts/rvm

# This shouldn't really be necessary... but the jenkins/rvm integration seems a
# bit wonky occasionally.
rvm use ree

# Start mysql if need be
pgrep mysql || sudo service mysql start

# Tapestry
title "Starting tapestry tests"

# There are a few submodules
git submodule init && git submodule update

# Tapestry is not set up yet to use --deployment
#bundle install --deployment
# --full-index to work around bundler issues 5378 and 5339
bundle install --full-index

sudo chmod 666 Gemfile.lock
sudo chmod 666 log/test.log
sudo rm -f config/database.yml
sudo rm -f config/environments/test.rb
sudo cp -f build/test/test.rb config/environments/
sudo cp -f build/test/database.yml config/
if [[ ! -f config/initializers/secret_token.rb ]]; then
  sudo cp -f config/initializers/secret_token.rb.example config/initializers/secret_token.rb
fi

export RAILS_ENV=test

bundle exec rake db:drop
bundle exec rake db:create
bundle exec rake db:setup
bundle exec rake test

ECODE=$?

if [[ "$ECODE" != "0" ]]; then
  title "!!!!!! TAPESTRY TESTS FAILED !!!!!!"
  EXITCODE=$(($EXITCODE + $ECODE))
fi

title "Tapestry tests complete"

exit $EXITCODE
