require 'spec_helper'

describe OpsWorks::CLI::Agent do
  describe '#version' do
    it 'should print the version' do
      version = OpsWorks::CLI::VERSION
      expect(subject).to receive(:say).with "opsworks-cli v#{version}"
      subject.version
    end
  end
end
