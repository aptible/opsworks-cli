require 'opsworks/stack'

module OpsWorks
  module CLI
    module Helpers
      module Options
        def parse_stacks(options = {})
          stacks = OpsWorks::Stack.all
          if options[:stack]
            stacks.select! { |stack| stack.name == options[:stack] }
          end
          stacks
        end
      end
    end
  end
end
