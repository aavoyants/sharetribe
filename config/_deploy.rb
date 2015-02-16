require 'capistrano/bundler'
require 'capistrano/rails'
require 'thinking_sphinx/capistrano'
require 'capistrano/rvm'

set :rvm_type, :user
set :rvm_ruby_version, '2.1.2'

default_run_options[:pty] = true  # Must be set for the password prompt from git to work

set :application, "quisine"
set :repository,  "git://github.com/aavoyants/sharetribe.git"
set :user, "deploy"  # The server's user for deploys
set :branch, 'production'
ssh_options[:forward_agent] = true

set :scm, :git
set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :deploy_via, :remote_cache

set :deploy_to, "/home/sharetribe"

set :domain, 'quisine.co'
set :host, "quisine.co"

# set :path, "$PATH:/var/lib/gems/1.8/bin"

role :app, host
role :web, host
role :db, host, :primary => true

set :rails_env, :production
set :use_sudo, false
set :thinking_sphinx_roles, :app

set :delayed_job_server_role, :worker
set :delayed_job_args, "-n 2"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  
  task :stop do ; end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
    
  task :symlinks_to_shared_path do
    run "rm -rf #{release_path}/public/images/listing_images"
    run "rm -rf #{release_path}/tmp/performance"
    run "ln -fs #{shared_path}/listing_images/ #{release_path}/public/images/listing_images"
    run "ln -fs #{shared_path}/performance/ #{release_path}/tmp/performance"
    run "ln -nfs #{shared_path}/system/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/system/session_secret #{release_path}/config/session_secret"
    run "ln -nfs #{shared_path}/system/config.yml #{release_path}/config/config.yml"
    run "ln -nfs #{shared_path}/system/gmaps_api_key.yml #{release_path}/config/gmaps_api_key.yml"
    run "ln -nfs #{shared_path}/system/translation.yml #{release_path}/config/translation.yml"
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
  end
    
end

after "deploy:update_code" do
  deploy.symlinks_to_shared_path
  whenever.update_crontab
  run("cd #{release_path} && /usr/bin/env #{rake} i18n:write_error_pages RAILS_ENV=production")
end

after "deploy:update" do
  thinking_sphinx.rebuild
end

after "deploy:setup" do
  thinking_sphinx.shared_sphinx_folder
  thinking_sphinx.configure
  thinking_sphinx.index
  thinking_sphinx.start
end

# Manage Delayed Job similarly as the server.
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

require 'config/boot'
require 'hoptoad_notifier/capistrano'