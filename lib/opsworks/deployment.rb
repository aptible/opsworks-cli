require 'opsworks/resource'

module OpsWorks
  class Deployment < Resource
    attr_accessor :id, :command, :status, :created_at, :custom_json, :app_id

    TIMEOUT = 300
    POLL_INTERVAL = 5
    API_LIMIT = 25

    # rubocop:disable MethodLength
    def self.wait(deployments, timeout = TIMEOUT)
      start_time = Time.now
      timeout ||= TIMEOUT
      while deployments.any?(&:running?)
        return if Time.now - start_time > timeout
        sleep POLL_INTERVAL
        updates = []
        running_deployments = deployments.select(&:running?)
        running_deployments.map(&:id).each_slice(API_LIMIT) do |slice|
          response = client.describe_deployments(
            deployment_ids: slice
          )
          updates += from_collection_response(response)
        end
        running_deployments.each do |deployment|
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
          command: hash[:command],
          created_at: hash[:created_at],
          status: hash[:status],
          custom_json: hash[:custom_json],
          app_id: hash[:app_id]
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
