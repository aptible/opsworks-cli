require_relative 'resource'
require_relative 'deployment'

module OpsWorks
  class App < Resource
    attr_accessor :id, :name, :revision

    def deployments
      Enumerator.new do |y|
        raw_deployments.each do |hash|
          y.yield Deployment.new(
            id: hash[:deployment_id],
            created_at: hash[:created_at],
            status: hash[:status]
          )
        end
      end
    end

    def last_deployment
      deployments.find(&:success?)
    end

    private

    def raw_deployments
      return @raw_deployments if @raw_deployments
      return [] unless id
      response = self.class.client.describe_deployments(app_id: id)
      @raw_deployments = response.data[:deployments]
    end
  end
end
