require 'omnivault'

module OpsWorks
  module CLI
    module Helpers
      module Credentials
        def fetch_credentials
          vault = Omnivault.autodetect
          vault.configure_aws!
        end

        def env_credentials?
          !!(ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'])
        end
      end
    end
  end
end
