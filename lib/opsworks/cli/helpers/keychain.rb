module OpsWorks
  module CLI
    module Helpers
      module Keychain
        KEYCHAIN = 'aws'

        def fetch_keychain_credentials(account = 'default')
          require 'aws-keychain-util/credential_provider'

          provider = AwsKeychainUtil::CredentialProvider.new(
            account, KEYCHAIN
          )
          Aws.config[:credentials] = provider if provider.set?
        rescue LoadError
          # Keychain utility is optional and only relevant on OS X
          nil
        end

        def env_credentials?
          !!(ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'])
        end
      end
    end
  end
end
