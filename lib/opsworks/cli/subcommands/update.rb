require 'aws'

module OpsWorks
  module CLI
    module Subcommands
      module Update
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def self.included(thor)
          thor.class_eval do
            include Helpers::Keychain
            include Helpers::Options

            desc 'update [--stack STACK]', 'Update OpsWorks custom cookbooks'
            option :stack
            def update
              fetch_keychain_credentials unless env_credentials?
              stacks = parse_stacks(options)
              stacks.each do |stack|
                say "Updating #{stack.name}..."
                stack.update_custom_cookbooks
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
