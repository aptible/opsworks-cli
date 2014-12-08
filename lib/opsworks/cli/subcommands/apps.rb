require 'opsworks/deployment'

module OpsWorks
  module CLI
    module Subcommands
      module Apps
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        # rubocop:disable PerceivedComplexity
        def self.included(thor)
          thor.class_eval do
            desc 'apps:deploy APP [--stack STACK]', 'Deploy an OpsWorks app'
            option :stack, type: :array
            define_method 'apps:deploy' do |name|
              fetch_keychain_credentials unless env_credentials?
              stacks = parse_stacks(options.merge(active: true))
              deployments = stacks.map do |stack|
                next unless (app = stack.find_app_by_name(name))
                say "Deploying to #{stack.name}..."
                stack.deploy_app(app)
              end
              deployments.compact!
              OpsWorks::Deployment.wait(deployments)
              unless deployments.all?(&:success?)
                failures = []
                deployments.each_with_index do |deployment, i|
                  failures << stacks[i].name unless deployment.success?
                end
                fail "Deploy failed on #{failures.join(', ')}"
              end
            end

            desc 'apps:status APP [--stack STACK]',
                 'Display the most recent deployment of an app'
            option :stack, type: :array
            define_method 'apps:status' do |name|
              fetch_keychain_credentials unless env_credentials?

              table = parse_stacks(options).map do |stack|
                next unless (app = stack.find_app_by_name(name))
                if (deployment = app.last_deployment)
                  deployed_at = formatted_time(deployment.created_at)
                else
                  deployed_at = '-'
                end
                [stack.name, name, "(#{app.revision})", deployed_at]
              end
              # Sort output in descending date order
              table.compact!
              table.sort! { |x, y| y.last <=> x.last }
              print_table table
            end

            private

            def formatted_time(timestamp)
              timestamp.strftime('%Y-%m-%d %H:%M:%S %Z')
            end
          end
        end
        # rubocop:enable PerceivedComplexity
        # rubocop:enable CyclomaticComplexity
        # rubocop:enable MethodLength
      end
    end
  end
end
