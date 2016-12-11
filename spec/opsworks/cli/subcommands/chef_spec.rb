require 'spec_helper'

describe OpsWorks::CLI::Agent do
  describe 'chef:sync' do
    let(:stacks) { Array.new(2) { Fabricate(:stack) } }
    let(:deployment) { Fabricate(:deployment, status: 'successful') }

    before { allow(subject).to receive(:say) }
    before { allow(OpsWorks::Deployment).to receive(:wait) }
    before { allow(OpsWorks::Stack).to receive(:all) { stacks } }
    before { allow(OpsWorks::Stack).to receive(:active) { stacks } }

    it 'should update custom cookbooks on all stacks' do
      expect(stacks[0]).to receive(:update_custom_cookbooks) { deployment }
      expect(stacks[1]).to receive(:update_custom_cookbooks) { deployment }
      subject.send('chef:sync')
    end

    it 'should optionally run on a subset of stacks' do
      expect(stacks[0]).to receive(:update_custom_cookbooks) { deployment }
      expect(stacks[1]).not_to receive(:update_custom_cookbooks)

      allow(subject).to receive(:options) { { stack: [stacks[0].name] } }
      subject.send('chef:sync')
    end

    it 'should fail if any update fails' do
      failure = Fabricate(:deployment, status: 'failed')
      expect(stacks[0]).to receive(:update_custom_cookbooks) { failure }

      allow(subject).to receive(:options) { { stack: [stacks[0].name] } }
      expect { subject.send('chef:sync') }.to raise_error
    end
  end
end
