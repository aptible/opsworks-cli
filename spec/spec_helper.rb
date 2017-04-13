$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

# Require library up front
require 'opsworks/cli'

require 'fabrication'

def opsworks_stub
  Aws::OpsWorks::Client.new(stub_responses: true)
end

RSpec.configure do |_config|
end
