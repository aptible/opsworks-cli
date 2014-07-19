module OpsWorks
  module CLI
    module Subcommands
      module Status
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def self.included(thor)
          thor.class_eval do
            include Helpers::Keychain
            include Helpers::Options

            desc 'status [--stack STACK] APP',
                 'Display the most recent deployment of an app'
            option :stack
            def status(name)
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
              table.compact!
              print_table table
            end

            private

            def formatted_time(timestamp)
              timestamp.strftime('%Y-%m-%d %H:%M:%S %Z')
            end
          end
        end
        # rubocop:enable CyclomaticComplexity
        # rubocop:enable MethodLength
      end
    end
  end
end
