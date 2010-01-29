$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module RailsUpgrade
  VERSION = '0.0.1'
end

require 'active_support'

require 'rails-upgrade/errors'

require 'rails-upgrade/upgraders/routes'
require 'rails-upgrade/upgraders/gems'
require 'rails-upgrade/upgraders/check'

