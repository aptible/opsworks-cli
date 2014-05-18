require_relative 'resource'

module OpsWorks
  class Deployment < Resource
    attr_accessor :id, :status, :created_at

    def success?
      status == 'successful'
    end

    def created_at
      Time.parse(@created_at)
    rescue
      @created_at
    end
  end
end
