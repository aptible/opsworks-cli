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
            option :timeout, type: :numeric, default: 300
            option :migrate, type: :boolean, default: false
            option :layer, type: :string
            define_method 'apps:deploy' do |name|
              stacks = parse_stacks(options.merge(active: true))
              deployments = stacks.map do |stack|
                next unless (app = stack.find_app_by_name(name))
                say "Deploying to #{stack.name}..."
                dpl = stack.deploy_app(
                  app,
                  layer: options[:layer],
                  args: { 'migrate' => [options[:migrate].to_s] }
                )
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
                fail "Deploy failed on #{failures.map(&:name).join(' ')}"
              end
            end

            desc 'apps:status APP [--stack STACK]',
                 'Display the most recent deployment of an app'
            option :stack, type: :array
            define_method 'apps:status' do |name|
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

            desc 'apps:create APP [--stack STACK]', 'Create a new OpsWorks app'
            option :stack, type: :array
            option :type, default: 'other'
            option :git_url
            option :shortname
            define_method 'apps:create' do |name|
              unless %w(other).include?(options[:type])
                fail "Unsupported type: #{options[:type]}"
              end

              fail 'Git URL not yet supported' if options[:git_url]

              stacks = parse_stacks(options)

              stacks.each do |stack|
                next if stack.apps.map(&:name).include?(name)
                say "Creating app on #{stack.name}."
                stack.create_app(name, options)
              end
            end

            desc 'apps:revision:update APP REVISION [--stack STACK]',
                 'Set the revision for an app'
            option :stack, type: :array
            define_method 'apps:revision:update' do |app_name, revision|
              stacks = parse_stacks(options.merge(active: true))
              stacks.each do |stack|
                next unless (app = stack.find_app_by_name(app_name))
                say "Updating #{stack.name} (from: #{app.revision})..."
                app.update_revision(revision)
              end
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
