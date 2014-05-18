require_relative 'resource'
require_relative 'deployment'

module OpsWorks
  class App < Resource
    attr_accessor :id, :name

    def deployments
      @deployments ||= initialize_deployments
      @deployments || []
    end

    def last_deployment
      deployments.find(&:success?)
    end

    private

    def initialize_deployments
      return nil unless id
      response = self.class.client.describe_deployments(app_id: id)
      response.data[:deployments].map do |hash|
        Deployment.new(
          id: hash[:deployment_id],
          created_at: hash[:created_at],
          status: hash[:status]
        )
      end
    end
  end
end
