require_relative 'resource'

module OpsWorks
  class Deployment < Resource
    attr_accessor :id, :status, :created_at

    POLL_INTERVAL = 5

    # rubocop:disable MethodLength
    def self.wait(deployments)
      while deployments.any?(&:running?)
        sleep POLL_INTERVAL
        response = client.describe_deployments(
          deployment_ids: deployments.map(&:id)
        )
        updates = from_collection_response(response)
        deployments.each do |deployment|
          update = updates.find { |u| u.id == deployment.id }
          deployment.status = update.status
        end
      end
    end
    # rubocop:enble MethodLength

    def self.from_collection_response(response)
      response.data[:deployments].map do |hash|
        new(
          id: hash[:deployment_id],
          created_at: hash[:created_at],
          status: hash[:status]
        )
      end
    end

    def self.from_response(response)
      new(id: response[:deployment_id])
    end

    def wait
      while deployment.running?
        sleep POLL_INTERVAL
        response = client.describe_deployments(deployment_ids: [id])
        update = from_collection_response(response).first
        deployment.status = update.status
      end
    end

    def running?
      status.nil? || status == 'running'
    end

    def success?
      status == 'successful'
    end

    def failed?
      status == 'failed'
    end

    def created_at
      Time.parse(@created_at)
    rescue
      @created_at
    end
  end
end
