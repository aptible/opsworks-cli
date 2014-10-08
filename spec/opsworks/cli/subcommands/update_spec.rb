require 'spec_helper'

describe OpsWorks::CLI::Agent do
  describe '#update' do
    let(:stacks) { 2.times.map { Fabricate(:stack) } }
    let(:deployment) { Fabricate(:deployment, status: 'successful') }

    before { allow(subject).to receive(:say) }
    before { allow(OpsWorks::Deployment).to receive(:wait) }
    before { allow(OpsWorks::Stack).to receive(:all) { stacks } }
    before { allow(OpsWorks::Stack).to receive(:active) { stacks } }

    it 'should update custom cookbooks on all stacks' do
      expect(stacks[0]).to receive(:update_custom_cookbooks) { deployment }
      expect(stacks[1]).to receive(:update_custom_cookbooks) { deployment }
      subject.update
    end

    it 'should optionally run on a subset of stacks' do
      expect(stacks[0]).to receive(:update_custom_cookbooks) { deployment }
      expect(stacks[1]).not_to receive(:update_custom_cookbooks)

      allow(subject).to receive(:options) { { stack: [stacks[0].name] } }
      subject.update
    end

    it 'should fail if any update fails' do
      failure = Fabricate(:deployment, status: 'failed')
      expect(stacks[0]).to receive(:update_custom_cookbooks) { failure }

      allow(subject).to receive(:options) { { stack: [stacks[0].name] } }
      expect { subject.update }.to raise_error
    end
  end
end
