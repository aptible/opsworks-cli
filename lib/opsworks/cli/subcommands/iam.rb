require 'opsworks/permission'

module OpsWorks
  module CLI
    module Subcommands
      module IAM
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def self.included(thor)
          thor.class_eval do
            desc 'iam:allow USER [--stack STACK]',
                 'Allow an IAM user on a stack'
            option :stack, type: :array
            option :ssh, type: :boolean, default: true
            option :sudo, type: :boolean, default: true
            define_method 'iam:allow' do |user|
              stacks = parse_stacks(options.merge(active: true))
              stacks.each do |stack|
                permission = stack.find_permission_by_user(user)
                next unless permission
                say "Updating permissions on #{stack.name}..."
                permission.update(ssh: options[:ssh], sudo: options[:sudo])
              end
            end

            desc 'iam:lockdown [--stack STACK]', 'Remove all stack permissions'
            option :stack, type: :array
            define_method 'iam:lockdown' do
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
