module OpsWorks
  module CLI
    module Subcommands
      module Deployments
        def self.included(thor)
          thor.class_eval do
            desc 'deployments:retry [--stack STACK]', 'Retry last deployment'
            option :stack, type: :array
            option :timeout, type: :numeric, default: 300
            define_method 'deployments:retry' do
              stacks = parse_stacks(options.merge(active: true))

              last_deployment = stacks.map do |stack|
                say "Loading last deployment for #{stack.name}"
                [stack, stack.deployments.max_by(&:created_at)]
              end

              will_retry = last_deployment.map do |stack, deployment|
                if deployment.nil?
                  say "Skipping stack #{stack.name}: no deployment"
                  next
                end

                if deployment.status == 'successful'
                  say "Skipping stack #{stack.name}: last deployment is " \
                      "#{deployment.status}"
                  next
                end

                say "Loading instance status for #{stack.name}"

                res = deployment.client.describe_commands(
                  deployment_id: deployment.id
                )

                retry_commands = res.commands.select do |command|
                  command.status != 'successful'
                end

                instance_ids = retry_commands.map(&:instance_id).to_a

                if instance_ids.empty?
                  say "Skipping #{stack.name}: no instances failed"
                  next
                end

                [stack, deployment, instance_ids]
              end.compact

              deployments = will_retry.map do |stack, dep, instance_ids|
                say "Retrying #{dep.command[:name]} in #{stack.name} " \
                    "on #{instance_ids.join ' '}"

                opts = {
                  command: dep.command,
                  instance_ids: instance_ids
                }
                opts[:app_id] = dep.app_id if dep.app_id
                opts[:custom_json] = dep.custom_json if dep.custom_json

                new_deployment = stack.create_deployment(opts)

                [stack, new_deployment]
              end

              say "Waiting #{options[:timeout]}s for deployments to finish"

              OpsWorks::Deployment.wait(deployments.map(&:last),
                                        options[:timeout])

              failures = deployments.map do |stack, deployment|
                next if deployment.success?
                stack
              end.compact

              unless failures.empty?
                raise "Deploy failed on #{failures.map(&:name).join(' ')}"
              end

              say "All #{deployments.size} deployments suceeded"
            end
          end
        end
      end
    end
  end
end
