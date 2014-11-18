require 'jsonpath'

require 'opsworks/resource'
require 'opsworks/app'
require 'opsworks/instance'
require 'opsworks/permission'

module OpsWorks
  # rubocop:disable ClassLength
  class Stack < Resource
    attr_accessor :id, :name, :custom_json

    AVAILABLE_CHEF_VERSIONS = %w(0.9 11.4 11.10)

    def self.all
      client.describe_stacks.data[:stacks].map do |hash|
        new(
          id: hash[:stack_id],
          name: hash[:name],
          custom_json: JSON.parse(hash[:custom_json])
        )
      end
    end

    def self.active
      all.select(&:active?)
    end

    def self.find_by_name(name)
      all.find { |stack| stack.name == name }
    end

    def self.latest_chef_version
      AVAILABLE_CHEF_VERSIONS.last
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

    def upgrade_chef(version, options = {})
      self.class.client.update_stack(
        stack_id: id,
        configuration_manager: { name: 'Chef', version: version },
        chef_configuration: { manage_berkshelf: options[:manage_berkshelf] }
      )
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

    def custom_json_at(key)
      JsonPath.new(key).first(custom_json)
    end

    def set_custom_json_at(key, value)
      self.custom_json = replace_hash_at_path(custom_json, key, value)

      self.class.client.update_stack(
        stack_id: id,
        custom_json: custom_json.to_json
      )
    end

    private

    def initialize_apps
      return [] unless id
      response = self.class.client.describe_apps(stack_id: id)
      App.from_collection_response(response)
    end

    # rubocop:disable Eval
    def replace_hash_at_path(hash, key, value)
      if value
        # REVIEW: Is there a better way to parse the JSON Path and ensure
        # a value at the location?
        path = JsonPath.new(key).path
        hash.default_proc = -> (h, k) { h[k] = Hash.new(&h.default_proc) }
        eval("hash#{path.join('')} = #{value.inspect}")
      else
        JsonPath.for(hash).gsub!(key) { value }.to_hash
      end

      hash
    end
    # rubocop:enable Eval

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
  # rubocop:enable ClassLength
end
