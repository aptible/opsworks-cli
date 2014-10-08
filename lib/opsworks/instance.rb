require 'opsworks/resource'

module OpsWorks
  class Instance < Resource
    attr_accessor :id, :hostname, :ec2_instance_id, :instance_type, :status

    def self.from_collection_response(response)
      response.data[:instances].map do |hash|
        new(
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
  end
end
