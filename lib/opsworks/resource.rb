module OpsWorks
  class Resource
    attr_reader :client

    def initialize(client, options = {})
      @client = client

      options.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end

    def self.account
      ENV['ACCOUNT'] || @account || 'opsworks-cli'
    end
  end
end
