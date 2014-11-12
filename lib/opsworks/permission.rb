require 'opsworks/resource'

module OpsWorks
  class Permission < Resource
    attr_accessor :id, :stack_id, :iam_user_arn, :ssh, :sudo

    def self.from_collection_response(response)
      response.data[:permissions].map do |hash|
        new(
          id: hash[:permission_id],
          stack_id: hash[:stack_id],
          iam_user_arn: hash[:iam_user_arn],
          sudo: hash[:allow_sudo],
          ssh: hash[:allow_ssh]
        )
      end
    end

    def user
      iam_user_arn.gsub(/^.*user\//, '')
    end

    def ssh?
      ssh
    end

    def sudo?
      sudo
    end

    def update(options = {})
      options[:ssh] = ssh if options[:ssh].nil?
      options[:sudo] = sudo if options[:sudo].nil?

      self.class.client.set_permission(
        stack_id: stack_id,
        iam_user_arn: iam_user_arn,
        allow_ssh: options[:ssh],
        allow_sudo: options[:sudo]
      )
      self.ssh = options[:ssh]
      self.sudo = options[:sudo]
    end
  end
end
