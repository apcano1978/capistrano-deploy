# config valid only for current version of Capistrano
lock '3.4.0'

def deploysecret(key)
  @deploy_secrets_yml ||= YAML.load_file('config/deploy-secrets.yml')[fetch(:stage).to_s]
  @deploy_secrets_yml[key.to_s]
end

set :rails_env, fetch(:stage)
set :rvm_ruby_version, deploysecret(:rvm_ruby_version)
set :rvm_type, :user

set :application, deploysecret(:application)
set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"
# If ssh access is restricted, probably you need to use https access
set :repo_url, deploysecret(:repo_url)

set :scm, :git
set :revision, `git rev-parse --short #{fetch(:branch)}`.strip

set :log_level, :info
set :pty, true
set :use_sudo, false

set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{log tmp public/system public/assets}

set :keep_releases, 10

set :local_user, ENV['USER']
set :deploy_user, deploysecret(:user)

# Run test before deploy
set :tests, []

# Config files should be copied by deploy:setup_config
set(:config_files, %w(
  log_rotation
  database.yml
  secrets.yml
  unicorn.rb
  sidekiq.yml
  nginx.conf
  unicorn_init.sh
))

set(:symlinks, [
                 {
                    source: 'nginx.conf',
                    link: "/etc/nginx/sites-enabled/#{fetch(:full_app_name)}"
                 },
                 {
                    source: 'unicorn_init.sh',
                    link: "/etc/init.d/unicorn_#{fetch(:full_app_name)}"
                 },
                 {
                     source: 'log_rotation',
                     link: "/etc/logrotate.d/#{fetch(:full_app_name)}"
                 }
             ])

namespace :deploy do
  # deploy:setup_config
  # remove the default nginx configuration as it will tend
  # to conflict with our configs.
  before 'deploy:setup_config', 'nginx:remove_default_vhost'
  before 'deploy:setup_config', 'nginx:enable_virtual_host'
  after 'deploy:setup_config', 'nginx:reload'
  after 'deploy:setup_config', 'nginx:executable_init'

  # Check right version of deploy branch
  before :deploy, 'deploy:check_revision'
  # Run test aund continue only if passed
  before :deploy, 'deploy:run_tests'
  # Compile assets locally and then rsync
  # after 'deploy:symlink:shared', 'deploy:compile_assets_locally'
  after :finishing, 'deploy:cleanup'
  # Restart unicorn
  after 'deploy:publishing', 'deploy:restart'
end
