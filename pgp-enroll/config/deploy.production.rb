set :application, "pgp-enroll"
set :domain,      "www-prod.oxf"
set :deploy_to,   "/var/www/enroll-dev.personalgenomes.org"
set :repository,  "http://dev.freelogy.org/svn/pgp-enroll/trunk"
set :rails_env,   "production"
set :config_files, ['database.yml']
