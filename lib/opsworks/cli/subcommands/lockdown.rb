require 'opsworks/permission'

module OpsWorks
  module CLI
    module Subcommands
      module Lockdown
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def self.included(thor)
          thor.class_eval do
            desc 'lockdown [--stack STACK]', 'Remove all stack permissions'
            option :stack, type: :array
            def lockdown
              fetch_keychain_credentials unless env_credentials?
              stacks = parse_stacks(options.merge(active: true))
              stacks.each do |stack|
                say "Locking down #{stack.name}..."
                stack.permissions.each do |permission|
                  permission.update(ssh: false, sudo: false)
                end
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
