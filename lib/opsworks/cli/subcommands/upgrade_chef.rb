require 'aws'
require 'opsworks/stack'

module OpsWorks
  module CLI
    module Subcommands
      module UpgradeChef
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def self.included(thor)
          thor.class_eval do
            include Helpers::Keychain
            include Helpers::Options

            desc 'upgrade-chef [--stack STACK]', 'Upgrade Chef version'
            option :stack, type: :array
            option :version
            option :manage_berkshelf, type: :boolean, default: false
            def upgrade_chef
              fetch_keychain_credentials unless env_credentials?
              stacks = parse_stacks(options.merge(active: true))
              version = OpsWorks::Stack.latest_chef_version
              stacks.each do |stack|
                say "Upgrading #{stack.name} to #{version}..."
                stack.upgrade_chef(version, options)
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
