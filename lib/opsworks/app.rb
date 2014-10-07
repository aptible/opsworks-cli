require 'opsworks/resource'
require 'opsworks/deployment'

module OpsWorks
  class App < Resource
    attr_accessor :id, :name, :revision

    def deployments
      @deployments ||= initialize_deployments
    end

    def last_deployment
      deployments.find(&:success?)
    end

    private

    def initialize_deployments
      return [] unless id
      response = self.class.client.describe_deployments(app_id: id)
      Deployment.from_collection_response(response)
    end
  end
end
