require 'thor'

require_relative 'helpers/options'
require_relative 'helpers/typecasts'

require_relative 'subcommands/chef'
require_relative 'subcommands/recipes'
require_relative 'subcommands/apps'
require_relative 'subcommands/iam'
require_relative 'subcommands/config'
require_relative 'subcommands/deployments'
require_relative 'subcommands/instances'

module OpsWorks
  module CLI
    class Agent < Thor
      include Thor::Actions

      include Helpers::Options
      include Helpers::Typecasts

      include Subcommands::Chef
      include Subcommands::Recipes
      include Subcommands::Apps
      include Subcommands::IAM
      include Subcommands::Config
      include Subcommands::Deployments
      include Subcommands::Instances

      desc 'version', 'Print OpsWorks CLI version'
      def version
        say "opsworks-cli v#{OpsWorks::CLI::VERSION}"
      end
    end
  end
end
