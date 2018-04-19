module OpsWorks
  class Instance < Resource
    attr_accessor :id, :hostname, :ec2_instance_id, :instance_type, :status

    FATAL_STATUSES = %w(
      connection_lost setup_failed start_failed stop_failed
    ).freeze

    SETTLED_STATUSES = (
      FATAL_STATUSES + %w(online stopped terminated)
    ).freeze

    def self.from_collection_response(client, response)
      response.data[:instances].map do |hash|
        new(
          client,
          id: hash[:instance_id],
          hostname: hash[:hostname],
          ec2_instance_id: hash[:ec2_instance_id],
          instance_type: hash[:instance_type],
          status: hash[:status]
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
