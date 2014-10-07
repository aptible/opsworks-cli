require 'opsworks/deployment'

module OpsWorks
  module CLI
    module Subcommands
      module Exec
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def self.included(thor)
          thor.class_eval do
            desc 'exec [--stack STACK] RECIPE', 'Execute a Chef recipe'
            option :stack, type: :array
            def exec(recipe)
              fetch_keychain_credentials unless env_credentials?
              stacks = parse_stacks(options)
              deployments = stacks.map do |stack|
                say "Executing recipe on #{stack.name}..."
                stack.execute_recipe(recipe)
              end
              OpsWorks::Deployment.wait(deployments)
              unless deployments.all?(&:success?)
                failures = []
                deployments.each_with_index do |deployment, i|
                  failures << stacks[i].name unless deployment.success?
                end
                fail "Command failed on #{failures.join(', ')}"
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
