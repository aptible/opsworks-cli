require 'opsworks/resource'
require 'opsworks/app'
require 'opsworks/instance'
require 'opsworks/permission'

module OpsWorks
  class Stack < Resource
    attr_accessor :id, :name

    def self.all
      client.describe_stacks.data[:stacks].map do |hash|
        new(id: hash[:stack_id], name: hash[:name])
      end
    end

    def self.active
      all.select(&:active?)
    end

    def self.find_by_name(name)
      all.find { |stack| stack.name == name }
    end

    def apps
      @apps ||= initialize_apps
    end

    def permissions
      @permissions ||= initialize_permissions
    end

    def find_permission_by_user(name)
      permissions.find { |permission| permission.user == name }
    end

    def find_app_by_name(name)
      apps.find { |app| app.name == name }
    end

    def instances
      @instances ||= initialize_instances
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

    def active?
      instances.any?(&:online?)
    end

    private

    def initialize_apps
      return [] unless id
      response = self.class.client.describe_apps(stack_id: id)
      App.from_collection_response(response)
    end

    def initialize_permissions
      return [] unless id
      response = self.class.client.describe_permissions(stack_id: id)
      Permission.from_collection_response(response)
    end

    def initialize_instances
      return [] unless id
      response = self.class.client.describe_instances(stack_id: id)
      Instance.from_collection_response(response)
    end

    def create_deployment(options = {})
      response = self.class.client.create_deployment(
        options.merge(stack_id: id)
      )
      Deployment.from_response(response)
    end
  end
end
