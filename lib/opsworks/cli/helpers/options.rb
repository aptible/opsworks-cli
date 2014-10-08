require 'opsworks/stack'

module OpsWorks
  module CLI
    module Helpers
      module Options
        def parse_stacks(options = {})
          if options[:stack]
            OpsWorks::Stack.all.select! do |stack|
              options[:stack].include?(stack.name)
            end
          else
            options[:active] ? OpsWorks::Stack.active : OpsWorks::Stack.all
          end
        end
      end
    end
  end
end
