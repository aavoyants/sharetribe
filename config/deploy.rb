set :application, 'quisine'
set :repo_url, 'git@github.com:aavoyants/sharetribe.git'
set :branch, 'production'

set :deploy_to, '/home/deploy/quisine'

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :delayed_job_server_role, :worker
# set :delayed_job_args, "-n 2"

# set :scm, :git
# set :repository, "git@github.com:aavoyants/sharetribe.git"
# set :branch, "production"
# set :repository_cache, "git_cache"
# set :deploy_via, :remote_cache
# set :ssh_options, { :forward_agent => true }

# set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke 'deploy:unicorn:restart'
  end

  after :finishing, 'deploy:cleanup'


  namespace :unicorn do
    pid_path = "#{release_path}/tmp/pids"
    unicorn_pid = "#{pid_path}/unicorn.pid"

    def run_unicorn
      execute "cd #{current_path} ; bundle exec unicorn_rails -E #{fetch(:rails_env)}"
      # execute cd #{release_path}  && ("RAILS_ENV=#{fetch(:stage)} /usr/local/rvm/bin/rvm default do bundle exec unicorn -E #{fetch(:rails_env)})"
    end

    desc 'Start unicorn'
    task :start do
      on roles(:app) do
        run_unicorn
      end
    end

    desc 'Stop unicorn'
    task :stop do
      on roles(:app) do
        if test "[ -f #{unicorn_pid} ]"
          execute :kill, "-QUIT `cat #{unicorn_pid}`"
        end
      end
    end

    desc 'Force stop unicorn (kill -9)'
    task :force_stop do
      on roles(:app) do
        if test "[ -f #{unicorn_pid} ]"
          execute :kill, "-9 `cat #{unicorn_pid}`"
          execute :rm, unicorn_pid
        end
      end
    end

    desc 'Restart unicorn'
    task :restart do
      on roles(:app) do
        if test "[ -f #{unicorn_pid} ]"
          execute :kill, "-USR2 `cat #{unicorn_pid}`"
        else
          run_unicorn
        end
      end
    end
  end

end