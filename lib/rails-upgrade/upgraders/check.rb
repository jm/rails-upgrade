# This is badly named/architected.  Guess who doesn't care right now...?? :)
require 'open3'

module RailsUpgrade
  module Upgraders
    class Check
      def initialize
        @issues = []
        
        raise NotInRailsAppError unless File.exist?("config/environment.rb")
      end
      
      def check(args)
        the_methods = (self.public_methods - Object.methods) - ["upgrade!", "check"]
        
        the_methods.each {|m| send m }
      end
      alias upgrade! check
      
      def check_ar_methods
        files = []
        ["find(:all", "find(:first", ":conditions =>", ":joins =>"].each do |v|
          lines = grep_for(v, "app/models/*")
          files += extract_filenames(lines)
        end
        
        if files
          alert(
            "Soon-to-be-deprecated ActiveRecord calls", 
            "Methods such as find(:all), find(:first), finds with conditions, and the :joins option will soon be deprecated.",
            "http://m.onkey.org/2010/1/22/active-record-query-interface",
            files
          )
        end

        lines = grep_for("named_scope", "app/models/*")
        files = extract_filenames(lines)
        
        if files
          alert(
            "named_scope is now just scope", 
            "The named_scope method has been renamed to just scope.",
            "http://github.com/rails/rails/commit/d60bb0a9e4be2ac0a9de9a69041a4ddc2e0cc914",
            files
          )
        end
      end
      
      def check_routes
        files = []
        ["map.", "ActionController::Routing::Routes", ".resources"].each do |v|
          lines = grep_for(v, "config/routes.rb")
          files += extract_filenames(lines)
        end
        
        if files
          alert(
            "Old router API", 
            "The router API has totally changed.",
            "http://yehudakatz.com/2009/12/26/the-rails-3-router-rack-it-up/",
            "config/routes.rb"
          )
        end
      end
      
      def check_environment
        unless File.exist?("config/application.rb")
          alert(
            "New file needed: config/application.rb", 
            "You need to add a config/application.rb.",
            "http://omgbloglol.com/post/353978923/the-path-to-rails-3-approaching-the-upgrade",
            "config/application.rb"
          )
        end
        
        lines = grep_for("config.", "config/environment.rb")
        files = extract_filenames(lines)
        
        if files
          alert(
            "Old environment.rb", 
            "environment.rb doesn't do what it used to; you'll need to move some of that into application.rb.",
            "http://omgbloglol.com/post/353978923/the-path-to-rails-3-approaching-the-upgrade",
            "config/environment.rb"
          )
        end
      end
      
      def check_gems
        lines = grep_for("config.gem ", "config/*.rb")
        files = extract_filenames(lines)
        
        if files
          alert(
            "Old gem bundling (config.gems)", 
            "The old way of bundling is gone now.  You need a Gemfile for bundler.",
            "http://omgbloglol.com/post/353978923/the-path-to-rails-3-approaching-the-upgrade",
            files
          )
        end
      end
      
      def check_mailers
        lines = grep_for("deliver_", "app/models/* app/controllers/* app/observers/*")
        files = extract_filenames(lines)
        
        if files
          alert(
            "Deprecated ActionMailer API", 
            "You're using the old ActionMailer API to send e-mails in a controller, model, or observer.",
            "http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3",
            files
          )
        end
        
        files = []
        ["recipients ", "attachment ", "subject ", "from "].each do |v|
          lines = grep_for(v, "app/models/*")
          files += extract_filenames(lines)
        end
        
        if files
          alert(
            "Old ActionMailer class API", 
            "You're using the old API in a mailer class.",
            "http://lindsaar.net/2010/1/26/new-actionmailer-api-in-rails-3",
            files
          )
        end
      end
      
      def check_generators
        generators = Dir.glob("vendor/plugins/**/generators/**/*.rb")

        unless generators.empty?
          lines = grep_for("def manifest", generators.join(" "))
          files = extract_filenames(lines)
        
          if files
            alert(
              "Old Rails generator API", 
              "A plugin in the app is using the old generator API (a new one may be available at http://github.com/trydionel/rails3-generators).",
              "http://blog.plataformatec.com.br/2010/01/discovering-rails-3-generators/",
              files
            )
          end
        end
      end
      
      def check_plugins
        # This list is off the wiki; will need to be updated often, esp. since RSpec is working on it
        bad_plugins = ["rspec", "rspec-rails", "hoptoad", "authlogic", "nifty-generators",
           "restful_authentication", "searchlogic", "cucumber", "cucumber-rails"]
           
        bad_plugins = bad_plugins.map {|p| p if File.exist?("vendor/plugins/#{p}") || !Dir.glob("vendor/gems/#{p}-*").empty?}.compact

        unless bad_plugins.empty?
          alert(
            "Known broken plugins", 
            "At least one plugin in your app is broken (according to the wiki).  Most of project maintainers are rapidly working towards compatability, but do be aware you may encounter issues.",
            "http://wiki.rubyonrails.org/rails/version3/plugins_and_gems",
            bad_plugins
          )
        end
      end
      
    private
      def grep_for(text, where = "*")
        value = ""
        
        # TODO: Figure out a pure Ruby way to do this that doesn't suck
        Open3.popen3("grep -r '#{text}' #{where}") do |stdin, stdout, stderr|
          value = stdout.read
        end
        
        value
      end
      
      def extract_filenames(output)
        return nil if output.empty?
        
        # I hate rescue nil as much as the next guy but I have a reason here at least...
        fnames = output.split("\n").map {|fn| fn.match(/^(.+?):/)[1] rescue nil}.compact
        fnames.uniq
      end
      
      def alert(title, text, more_info_url, culprits)
        puts title.red.bold
        puts text.white
        puts "More information: ".white.bold + more_info_url.blue
        puts
        puts "The culprits: ".white
        culprits.each do |c|
          puts "\t- #{c}".yellow
        end
      ensure
        puts "".reset
      end
    end
  end
end