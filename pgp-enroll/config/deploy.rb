set :application, 'pgp'
set :repository,  'http://svn.jayunit.net/pgpproto/trunk'
set :deploy_to,   '/var/www/pgp-staging.hugcapacitor.com'
set :deploy_via,  :remote_cache 

ssh_options[:port] = 33333
ssh_options[:username] = 'jason'

role :app, 'pgp-staging.hugcapacitor.com'
role :web, 'pgp-staging.hugcapacitor.com'
role :db,  'pgp-staging.hugcapacitor.com', :primary => true

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  desc “A setup task to put shared system, log, and database directories in place”
  task :setup, :roles => [:app, :db, :web] do
    run <<-CMD
      mkdir -p -m 775 #{release_path} #{shared_path}/system #{shared_path}/db &&
      mkdir -p -m 777 #{shared_path}/log
    CMD
  end
end

