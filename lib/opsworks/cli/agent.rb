require 'thor'
require 'aws'

require_relative 'helpers/keychain'
require_relative 'helpers/options'

require_relative 'subcommands/update'
require_relative 'subcommands/exec'
require_relative 'subcommands/deploy'
require_relative 'subcommands/status'
require_relative 'subcommands/allow'
require_relative 'subcommands/lockdown'
require_relative 'subcommands/upgrade_chef'

module OpsWorks
  module CLI
    class Agent < Thor
      include Thor::Actions

      include Subcommands::Update
      include Subcommands::Exec
      include Subcommands::Deploy
      include Subcommands::Status
      include Subcommands::Allow
      include Subcommands::Lockdown
      include Subcommands::UpgradeChef

      desc 'version', 'Print OpsWorks CLI version'
      def version
        say "opsworks-cli v#{OpsWorks::CLI::VERSION}"
      end
    end
  end
end
