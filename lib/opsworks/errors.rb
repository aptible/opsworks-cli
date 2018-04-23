module OpsWorks
  module Errors
    class StackInFatalState < StandardError
      attr_reader :stack, :instances

      def initialize(stack, instances)
        @stack = stack
        @instances = instances
        names = instances.map(&:hostname).join(' ')
        super("Instances entered a fatal state on #{stack.name}: #{names}")
      end
    end
  end
end
