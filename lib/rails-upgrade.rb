$:.unshift(File.dirname(__FILE__))

module RailsUpgrade
  VERSION = '0.0.2'
end

require 'active_support'

# This is ridiculous but I don't feel like fighting with require
require File.dirname(__FILE__) + '/rails-upgrade/errors'

require File.dirname(__FILE__) + '/rails-upgrade/upgraders/routes'
require File.dirname(__FILE__) + '/rails-upgrade/upgraders/gems'
require File.dirname(__FILE__) + '/rails-upgrade/upgraders/check'

