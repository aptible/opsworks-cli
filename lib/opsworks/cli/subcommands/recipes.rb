module OpsWorks
  module CLI
    module Subcommands
      module Recipes
        def self.included(thor)
          thor.class_eval do
            desc 'recipes:run RECIPE [--stack STACK]', 'Execute a Chef recipe'
            option :stack, type: :array
            option :timeout, type: :numeric, default: 300
            option :layer, type: :string
            define_method 'recipes:run' do |recipe|
              stacks = parse_stacks(options.merge(active: true))
              deployments = stacks.map do |stack|
                say "Executing recipe on #{stack.name}..."
                stack.execute_recipe(recipe, layer: options[:layer])
              end
              OpsWorks::Deployment.wait(deployments, options[:timeout])
              unless deployments.all?(&:success?)
                failures = []
                deployments.each_with_index do |deployment, i|
                  failures << stacks[i].name unless deployment.success?
                end
                raise "Command failed on #{failures.join(', ')}"
              end
            end

            desc 'recipes:add LAYER EVENT RECIPE [--stack STACK]',
                 'Add a recipe to a given layer and lifecycle event'
            option :stack, type: :array
            define_method 'recipes:add' do |layername, event, recipe|
              stacks = parse_stacks(options)
              stacks.each do |stack|
                layer = stack.layers.find { |l| l.shortname == layername }
                next unless layer
                next if layer.custom_recipes[event].include?(recipe)

                say "Adding recipe to #{stack.name}."
                layer.add_custom_recipe(event, recipe)
              end
            end

            desc 'recipes:rm LAYER EVENT RECIPE [--stack STACK]',
                 'Remove a recipe from a given layer and lifecycle event'
            option :stack, type: :array
            define_method 'recipes:rm' do |layername, event, recipe|
              stacks = parse_stacks(options)
              stacks.each do |stack|
                layer = stack.layers.find { |l| l.shortname == layername }
                next unless layer
                next unless layer.custom_recipes[event].include?(recipe)

                say "Removing recipe from #{stack.name}."
                layer.remove_custom_recipe(event, recipe)
              end
            end
          end
        end
      end
    end
  end
end
