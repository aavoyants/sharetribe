# Load DSL and Setup Up Stages
require 'capistrano/setup'
require 'thinking_sphinx/capistrano'

# Includes default deployment tasks
require 'capistrano/deploy'

require 'capistrano/bundler'
require 'capistrano/rails'

require 'capistrano/rvm'

set :rvm_custom_path, '~/.rvm'
set :rvm_ruby_version, '2.1.2'

# Includes tasks from other gems included in your Gemfile


# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
