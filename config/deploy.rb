# Deploy Config
# =============
#
# Copy this file to config/deploy.rb and customize it as needed.
# Then run `cap errbit:setup` to set up your server and finally
# `cap deploy` whenever you would like to deploy Errbit. Refer
# to ./docs/deployment/capistrano.md for more info

# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'errbit'
set :repo_url, 'https://github.com/zeuswpi/errbit.git'
set :branch, ENV['branch'] || 'master'
set :deploy_to, '/home/errbit/app'
set :keep_releases, 5

set :pty, true
set :ssh_options, forward_agent: true

set :linked_files, fetch(:linked_files, []) + %w(
  .env
  config/config.yml
  config/mongoid.yml
  config/initializers/secret_token.rb
)

set :linked_dirs, fetch(:linked_dirs, []) + %w(
  log
  tmp/cache tmp/pids tmp/sockets
  vendor/bundle
)

# check out capistrano-rbenv documentation
# set :rbenv_type, :system
# set :rbenv_path, '/usr/local/rbenv'
# set :rbenv_ruby, File.read(File.expand_path('../../.ruby-version', __FILE__)).strip
# set :rbenv_roles, :all

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app) do
      with rails_env: fetch(:rails_env) do
        execute "touch #{current_path}/tmp/restart.txt"
      end
    end
  end

  after :publishing, :restart

end

namespace :db do
  desc "Create and setup the mongo db"
  task :setup do
    on roles(:db) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'errbit:bootstrap'
        end
      end
    end
  end
end
