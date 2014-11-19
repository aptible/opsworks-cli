require 'aws'
require 'opsworks/stack'

module OpsWorks
  module CLI
    module Subcommands
      module Config
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def self.included(thor)
          thor.class_eval do
            include Helpers::Keychain
            include Helpers::Options

            desc 'config:get KEY [--stack STACK]', 'Get a single config value'
            option :stack, type: :array
            define_method 'config:get' do |key|
              fetch_keychain_credentials unless env_credentials?
              table = parse_stacks(options).map do |stack|
                value = stack.custom_json_at(key)
                [stack.name, value || '(null)']
              end
              table.compact!
              table.sort! { |x, y| x.first <=> y.first }
              print_table table
            end

            desc 'config:set KEY VALUE [--stack STACK]', 'Set a config value'
            option :stack, type: :array
            define_method 'config:set' do |key, value|
              fetch_keychain_credentials unless env_credentials?
              parse_stacks(options).each do |stack|
                say "Updating #{stack.name}..."
                stack.set_custom_json_at(key, value)
              end
            end

            desc 'config:unset KEY [--stack STACK]', 'Unset a config value'
            option :stack, type: :array
            define_method 'config:unset' do |key|
              fetch_keychain_credentials unless env_credentials?
              parse_stacks(options).map do |stack|
                say "Updating #{stack.name}..."
                stack.set_custom_json_at(key, nil)
              end
            end
          end
        end
        # rubocop:enable CyclomaticComplexity
        # rubocop:enable MethodLength
      end
    end
  end
end
