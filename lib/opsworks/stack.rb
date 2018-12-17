module OpsWorks
  class Stack < Resource
    attr_accessor :id, :name, :custom_json

    AVAILABLE_CHEF_VERSIONS = %w(0.9 11.4 11.10).freeze
    DEPLOY_NO_INSTANCES_ERROR = 'Please provide at least an instance ID of ' \
                                'one running instance'.freeze

    def self.all
      regions = Aws.partition('aws').regions.select do |region|
        region.services.include?('OpsWorks')
      end.map(&:name)

      stack_queue = Queue.new

      threads = regions.map do |region|
        Thread.new do
          client = Aws::OpsWorks::Client.new(region: region)
          client.describe_stacks.stacks.each do |stack|
            stack_queue << new(
              client,
              id: stack.stack_id,
              name: stack.name,
              custom_json: JSON.parse(stack.custom_json || '{}')
            )
          end
        end
      end
      threads.each(&:join)

      stacks = []
      stacks << stack_queue.pop until stack_queue.empty?
      stacks
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

    def layers
      @layers ||= initialize_layers
    end

    def deployments
      @deployments ||= initialize_deployments
    end

    def update_chef(options)
      params = {
        stack_id: id,
        configuration_manager: { name: 'Chef', version: options[:version] },
        chef_configuration: {
          manage_berkshelf: options[:manage_berkshelf],
          berkshelf_version: options[:berkshelf_version]
        }
      }
      if options[:cookbook_git_url]
        params[:custom_cookbooks_source] = {
          type: 'git',
          url: options[:cookbook_git_url],
          revision: options[:cookbook_branch] || 'master'
        }
      elsif options[:cookbook_s3_url]
        params[:custom_cookbooks_source] = {
          type: 's3',
          url: options[:cookbook_s3_url],
          username: options[:cookbook_username],
          password: options[:cookbook_password]
        }
      end
      client.update_stack(params)
    end

    def update_custom_cookbooks
      create_deployment(command: { name: 'update_custom_cookbooks' })
    end

    def execute_recipe(recipe, layer: nil)
      deploy_args = {
        command: {
          name: 'execute_recipes',
          args: { 'recipes' => [recipe] }
        }
      }

      deploy_args[:layer_ids] = [layer_id_from_name(layer)] if layer

      create_deployment(**deploy_args)
    end

    def deploy_app(app, layer: nil, args: {})
      raise 'App not found' unless app && app.id

      deploy_args = {
        app_id: app.id,
        command: {
          name: 'deploy',
          args: args
        }
      }

      deploy_args[:layer_ids] = [layer_id_from_name(layer)] if layer

      create_deployment(**deploy_args)
    end

    def create_deployment(options = {})
      response = client.create_deployment(
        options.merge(stack_id: id)
      )
    rescue Aws::OpsWorks::Errors::ValidationException => e
      raise unless e.message == DEPLOY_NO_INSTANCES_ERROR
    else
      Deployment.from_response(client, response)
    end

    def active?
      instances.any?(&:online?)
    end

    def custom_json_at(key)
      JsonPath.new(key).first(custom_json)
    end

    def set_custom_json_at(key, value)
      self.custom_json = replace_hash_at_path(custom_json, key, value)

      client.update_stack(
        stack_id: id,
        custom_json: JSON.pretty_generate(custom_json)
      )
    end

    def create_app(name, options = {})
      options = options.slice(:type, :shortname).merge(stack_id: id, name: name)
      client.create_app(options)
    end

    def settled?
      instances = initialize_instances
      fatal = instances.select(&:fatal?)
      raise Errors::StackInFatalState.new(self, fatal) if fatal.any?
      instances.all?(&:settled?)
    end

    private

    # rubocop:disable Eval
    def replace_hash_at_path(hash, key, value)
      path = JsonPath.new(key).path
      if !value.nil?
        # REVIEW: Is there a better way to parse the JSON Path and ensure
        # a value at the location?
        (0...(path.length - 1)).each do |i|
          eval("hash#{path[0..i].join('')} ||= {}")
        end
        eval("hash#{path.join('')} = #{value.inspect}")
      elsif JsonPath.new(key).on(hash).count > 0
        # Path value is present, but we need to unset it
        leaf_key = eval(path[-1]).first
        eval("hash#{path[0...-1].join('')}.delete(#{leaf_key.inspect})")
      end

      hash
    end
    # rubocop:enable Eval

    def layer_id_from_name(shortname)
      layer = layers.find { |l| l.shortname == shortname }
      raise "Layer #{layer} not found" unless layer
      layer.id
    end

    def initialize_apps
      return [] unless id
      response = client.describe_apps(stack_id: id)
      App.from_collection_response(client, response)
    end

    def initialize_permissions
      return [] unless id
      response = client.describe_permissions(stack_id: id)
      Permission.from_collection_response(client, response)
    end

    def initialize_instances
      return [] unless id
      response = client.describe_instances(stack_id: id)
      Instance.from_collection_response(client, response)
    end

    def initialize_layers
      return [] unless id
      response = client.describe_layers(stack_id: id)
      Layer.from_collection_response(client, response)
    end

    def initialize_deployments
      return [] unless id
      response = client.describe_deployments(stack_id: id)
      Deployment.from_collection_response(client, response)
    end
  end
end
