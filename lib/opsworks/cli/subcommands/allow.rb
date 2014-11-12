require 'opsworks/permission'

module OpsWorks
  module CLI
    module Subcommands
      module Allow
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def self.included(thor)
          thor.class_eval do
            desc 'allow USER [--stack STACK]', 'Allow an IAM user on a stack'
            option :stack, type: :array
            option :ssh, type: :boolean, default: true
            option :sudo, type: :boolean, default: true
            def allow(user)
              fetch_keychain_credentials unless env_credentials?
              stacks = parse_stacks(options.merge(active: true))
              stacks.each do |stack|
                permission = stack.find_permission_by_user(user)
                next unless permission
                say "Updating permissions on #{stack.name}..."
                permission.update(ssh: options[:ssh], sudo: options[:sudo])
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
