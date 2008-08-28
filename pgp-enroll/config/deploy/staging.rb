# For migrations
set :rails_env, 'staging'

# Who are we?
set :application, 'pgp'
set :repository,  'http://dev.freelogy.org/svn/pgp-enroll/trunk'

# Where to deploy to?
role :app, 'www-dev.oxf'
role :web, 'www-dev.oxf'
role :db,  'www-dev.oxf', :primary => true

# Deploy details
set :deploy_to,   '/var/www/enroll-dev.personalgenomes.org'
set :deploy_via,  :remote_cache
set :scm_command, 'svn'
set :user,        'www-data'
set :use_sudo,    false

