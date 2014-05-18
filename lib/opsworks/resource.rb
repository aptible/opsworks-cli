module OpsWorks
  class Resource
    def initialize(options = {})
      options.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end

    def self.client
      @client ||= AWS::OpsWorks::Client.new
    end

    def self.account
      ENV['ACCOUNT'] || @account || 'opsworks-cli'
    end
  end
end
