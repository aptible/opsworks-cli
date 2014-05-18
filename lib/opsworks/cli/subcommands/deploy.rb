module OpsWorks
  module CLI
    module Subcommands
      module Deploy
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def self.included(thor)
          thor.class_eval do
            desc 'deploy [--stack STACK] APP', 'Deploy an OpsWorks app'
            option :stack
            def deploy(name)
              fetch_keychain_credentials unless env_credentials?
              stacks = parse_stacks(options)
              stacks.each do |stack|
                next unless (app = stack.find_app_by_name(name))
                say "Deploying to #{stack.name}..."
                stack.deploy_app(app)
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
