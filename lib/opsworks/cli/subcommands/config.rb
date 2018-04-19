module OpsWorks
  module CLI
    module Subcommands
      module Config
        def self.included(thor)
          thor.class_eval do
            desc 'config:get KEY [--stack STACK]', 'Get a single config value'
            option :stack, type: :array
            define_method 'config:get' do |key|
              table = parse_stacks(options).map do |stack|
                value = stack.custom_json_at(key)
                [stack.name, value.nil? ? '(null)' : value]
              end
              table.compact!
              table.sort! { |x, y| x.first <=> y.first }
              print_table table
            end

            desc 'config:set KEY VALUE [--stack STACK]', 'Set a config value'
            option :stack, type: :array
            define_method 'config:set' do |key, value|
              parse_stacks(options).each do |stack|
                say "Updating #{stack.name}..."
                stack.set_custom_json_at(key, typecast_string_argument(value))
              end
            end

            desc 'config:unset KEY [--stack STACK]', 'Unset a config value'
            option :stack, type: :array
            define_method 'config:unset' do |key|
              parse_stacks(options).map do |stack|
                say "Updating #{stack.name}..."
                stack.set_custom_json_at(key, nil)
              end
            end
          end
        end
      end
    end
  end
end
