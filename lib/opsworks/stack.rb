require_relative 'resource'
require_relative 'app'

module OpsWorks
  class Stack < Resource
    attr_accessor :id, :name

    def self.all
      client.describe_stacks.data[:stacks].map do |hash|
        new(id: hash[:stack_id], name: hash[:name])
      end
    end

    def self.find_by_name(name)
      all.find { |stack| stack.name == name }
    end

    def apps
      Enumerator.new do |y|
        raw_apps.each do |hash|
          revision = hash[:app_source][:revision] if hash[:app_source]
          y.yield App.new(id: hash[:app_id],
                          name: hash[:name],
                          revision: revision)
        end
      end
    end

    def find_app_by_name(name)
      apps.find { |app| app.name == name }
    end

    def update_custom_cookbooks
      create_deployment(command: { name: 'update_custom_cookbooks' })
    end

    def execute_recipe(recipe)
      create_deployment(
        command: {
          name: 'execute_recipes',
          args: { 'recipes' => [recipe] }
        }
      )
    end

    def deploy_app(app)
      fail 'App not found' unless app && app.id
      create_deployment(app_id: app.id, command: { name: 'deploy' })
    end

    private

    def raw_apps
      return @raw_apps if @raw_apps
      return [] unless id
      @raw_apps = self.class.client.describe_apps(stack_id: id).data[:apps]
    end

    def create_deployment(options = {})
      self.class.client.create_deployment(options.merge(stack_id: id))
    end
  end
end
