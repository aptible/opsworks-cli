module OpsWorks
  module CLI
    module Subcommands
      module Instances
        def self.included(thor)
          thor.class_eval do
            desc 'instances:status [--stack STACK]',
                 'Display instance status for a stack'
            option :stack, type: :array
            define_method 'instances:status' do
              stacks = parse_stacks(options)
              stacks.each do |stack|
                stack.instances.each do |instance|
                  arr = [
                    stack.name,
                    instance.hostname,
                    instance.status
                  ]
                  # TODO: Why does a EOL tab break say?
                  if (errors = instance.service_errors).any?
                    arr << errors.join(', ')
                  end
                  say arr.join("\t")
                end
              end
            end

            desc 'instances:wait [--timeout TIMEOUT] [--stack STACK]',
                 'Wait for all instances to settle'
            option :timeout, type: :numeric, default: 300
            option :stack, type: :array
            define_method 'instances:wait' do
              deadline = Time.now + options[:timeout]
              stacks = parse_stacks(options)

              loop do
                stacks = stacks.reject(&:settled?)
                break if stacks.empty?

                if Time.now > deadline
                  raise "Stacks did not settle: #{stacks.map(&:name).join(' ')}"
                end

                sleep 5
              end
            end

            desc 'instances:setup [--stack STACK]',
                 'Retry setup on any instances where it failed'
            option :stack, type: :array
            define_method 'instances:setup' do
              stacks = parse_stacks(options)
              stacks.each do |stack|
                stack.instances.each do |instance|
                  next unless instance.setup_failed?
                  say "Running setup on #{stack.name} #{instance.hostname}"

                  stack.create_deployment(
                    command: { name: 'setup' },
                    instance_ids: [instance.id]
                  )
                end
              end
            end
          end
        end
      end
    end
  end
end
