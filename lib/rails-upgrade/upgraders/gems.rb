module RailsUpgrade
  module Upgraders
    class Gems
      def upgrade!(args)
        if File.exists?("config/environment.rb")
          generate_gemfile
        else
          raise FileNotFoundError, "Can't find environment.rb [config/environment.rb]!"
        end
      end
      
      def generate_gemfile
        environment_file = File.open("config/environment.rb").read
        
        # Get each line that starts with config.gem
        gem_lines = environment_file.split("\n").select {|l| l =~ /^\s*config\.gem/}
        
        # yay hax
        config = GemfileGenerator.new
        eval(gem_lines.join("\n"))
        puts config.output
      end
    end
    
    class GemfileGenerator
      def initialize
        @gems = []
      end
      
      def gem(name, options={})
        data = {}
        
        # Add new keys from old keys
        data[:require_as] = options[:lib] if options[:lib]
        data[:source] = options[:source] if options[:source]
        
        version = options[:version]
        @gems << [name, version, data]
      end
      
      def output
        preamble = <<STR
# Edit this Gemfile to bundle your application's dependencies.
# This preamble is the current preamble for Rails 3 apps; edit as needed.
directory "/path/to/rails", :glob => "{*/,}*.gemspec"
git "git://github.com/rails/arel.git"
git "git://github.com/rails/rack.git"
gem "rails", "3.0.pre"
STR
        preamble + "\n" + generate_upgraded_code
      end
      
      def generate_upgraded_code    
        code = @gems.map do |name, version, data|
          version_string = (version ? ", '#{version}'" : "")
          # omg hax.  again.
          data_string = data.inspect.match(/^\{(.*)\}$/)[1]
          
          "gem '#{name}'#{version_string}, #{data_string}"
        end.join("\n")
      end
    end
  end
end