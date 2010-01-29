module RailsUpgrade
  class CLI
    class <<self
      def execute(stdout, arguments=[])
        command = arguments.pop.capitalize

        if RailsUpgrade::Upgraders.const_defined?(command)
          klass = RailsUpgrade::Upgraders.const_get(command)
          instance = klass.new
          
          instance.upgrade!(arguments)
        else
          usage
        end
      end
      
      def usage
        puts "fail"
      end
    end
  end
end