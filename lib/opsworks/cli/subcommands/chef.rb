module OpsWorks
  module CLI
    module Subcommands
      module Chef
        def self.included(thor)
          thor.class_eval do
            desc 'chef:configure [--stack STACK]', 'Configure Chef/Berkshelf'
            option :stack, type: :array
            option :version, default: OpsWorks::Stack.latest_chef_version
            option :manage_berkshelf, type: :boolean, default: true
            option :berkshelf_version, default: '3.2.0'
            option :cookbook_git_url
            option :cookbook_branch
            option :cookbook_s3_url
            option :cookbook_username
            option :cookbook_password
            define_method 'chef:configure' do
              stacks = parse_stacks(options.merge(active: true))
              stacks.each do |stack|
                say "Configuring Chef #{options[:version]} on #{stack.name}..."
                stack.update_chef(options)
              end
            end

            desc 'chef:sync [--stack STACK]', 'Sync OpsWorks custom cookbooks'
            option :stack, type: :array
            option :timeout, type: :numeric, default: 300
            define_method 'chef:sync' do
              stacks = parse_stacks(options.merge(active: true))
              deployments = stacks.map do |stack|
                say "Syncing #{stack.name}..."
                dpl = stack.update_custom_cookbooks
                next unless dpl
                [stack, dpl]
              end.compact

              OpsWorks::Deployment.wait(deployments.map(&:last),
                                        options[:timeout])

              failures = deployments.map do |stack, deployment|
                next if deployment.success?
                stack
              end.compact

              unless failures.empty?
                raise "Deploy failed on #{failures.map(&:name).join(', ')}"
              end
            end
          end
        end
      end
    end
  end
end
