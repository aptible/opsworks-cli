$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

# Require library up front
require 'opsworks/cli'

require 'fabrication'
require 'omnivault'

RSpec.configure do |config|
  config.before do
    allow(AWS::OpsWorks::Client).to receive(:new) { double.as_null_object }
    allow(AWS).to receive(:config)

    allow(Omnivault).to receive(:autodetect) { double.as_null_object }
  end
end
