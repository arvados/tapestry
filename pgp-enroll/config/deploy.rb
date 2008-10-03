set :application, "pgp-enroll"
set :domain,      "www-dev.oxf"
set :deploy_to,   "/var/www/enroll-dev.personalgenomes.org"
set :repository,  "http://dev.freelogy.org/svn/pgp-enroll/trunk"
set :rails_env,   "staging"
set :config_files, ['database.yml']
# TODO: branches/stable

#OLD CAPISTRANO CONFIG:
# # For migrations
# set :rails_env, 'staging'
# 
# # Who are we?
# set :application, 'pgp'
# set :repository,  'http://dev.freelogy.org/svn/pgp-enroll/trunk'
# 
# # Where to deploy to?
# role :app, 'www-dev.oxf'
# role :web, 'www-dev.oxf'
# role :db,  'www-dev.oxf', :primary => true
# 
# # Deploy details
# set :deploy_to,   '/var/www/enroll-dev.personalgenomes.org'
# set :deploy_via,  :remote_cache
# set :scm_command, 'svn'
# set :user,        'www-data'
# set :use_sudo,    false
# 
# 
# # Main deploy.rb
# set :stages, %w(staging production)
# set :default_stage, 'staging'
# require 'capistrano/ext/multistage'
# 
# # ssh_options[:port] = 33333
# # ssh_options[:username] = 'jason'
# 
# 
# namespace :deploy do
#   desc "Restarting mod_rails with restart.txt"
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "touch #{current_path}/tmp/restart.txt"
#   end
# 
#   [:start, :stop].each do |t|
#     desc "#{t} task is a no-op with mod_rails"
#     task t, :roles => :app do ; end
#   end
# 
#   desc "A setup task to put shared system, log, and database directories in place"
#   task :setup, :roles => [:app, :db, :web] do
#     run <<-CMD
#       mkdir -p -m 775 #{release_path} #{shared_path}/system #{shared_path}/db &&
#       mkdir -p -m 777 #{shared_path}/log
#     CMD
#   end
# end
# 
# 
# 
