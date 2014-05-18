module OpsWorks
  module CLI
    module Subcommands
      module Exec
        # rubocop:disable MethodLength
        # rubocop:disable CyclomaticComplexity
        def self.included(thor)
          thor.class_eval do
            desc 'exec [--stack STACK] RECIPE', 'Execute a Chef recipe'
            option :stack
            def exec(recipe)
              fetch_keychain_credentials unless env_credentials?
              stacks = parse_stacks(options)
              stacks.each do |stack|
                say "Executing recipe on #{stack.name}..."
                stack.execute_recipe(recipe)
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
