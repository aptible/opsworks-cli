require 'aws'
require 'opsworks/stack'

module OpsWorks
  module CLI
    module Subcommands
      module Chef
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def self.included(thor)
          thor.class_eval do
            desc 'chef:configure [--stack STACK]', 'Configure Chef/Berkshelf'
            option :stack, type: :array
            option :version, default: OpsWorks::Stack.latest_chef_version
            option :manage_berkshelf, type: :boolean, default: false
            option :berkshelf_version, default: '3.2.0'
            option :cookbook_git_url
            option :cookbook_branch
            option :cookbook_s3_url
            option :cookbook_username
            option :cookbook_password
            define_method 'chef:configure' do
              fetch_credentials unless env_credentials?
              stacks = parse_stacks(options.merge(active: true))
              stacks.each do |stack|
                say "Configuring Chef #{options[:version]} on #{stack.name}..."
                stack.update_chef(options)
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
