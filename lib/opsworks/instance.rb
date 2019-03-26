module OpsWorks
  class Instance < Resource
    attr_accessor :id, :hostname, :ec2_instance_id, :instance_type, :status,
                  :service_errors

    FATAL_STATUSES = %w(
      connection_lost setup_failed start_failed stop_failed
    ).freeze

    SETTLED_STATUSES = (
      FATAL_STATUSES + %w(online stopped terminated)
    ).freeze

    def self.from_collection_response(client, response)
      response.data[:instances].map do |hash|
        # If instance is in start_failed status, grab the service errors to
        # help explain why
        if hash[:status] == 'start_failed'
          instance_id = hash[:instance_id]
          raw = client.describe_service_errors(instance_id: instance_id)
          service_errors = raw[:service_errors].map { |e| e[:message] }
        else
          service_errors = []
        end

        new(
          client,
          id: hash[:instance_id],
          hostname: hash[:hostname],
          ec2_instance_id: hash[:ec2_instance_id],
          instance_type: hash[:instance_type],
          status: hash[:status],
          service_errors: service_errors
        )
      end
    end

    def online?
      status == 'online'
    end

    def setup_failed?
      status == 'setup_failed'
    end

    def fatal?
      FATAL_STATUSES.include?(status)
    end

    def settled?
      SETTLED_STATUSES.include?(status)
    end
  end
end
