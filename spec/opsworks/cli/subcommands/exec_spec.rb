require 'spec_helper'

describe OpsWorks::CLI::Agent do
  describe '#exec' do
    let(:recipe) { 'hotpockets::install' }

    let(:stacks) { 2.times.map { Fabricate(:stack) } }
    let(:deployment) { Fabricate(:deployment, status: 'successful') }

    before { allow(subject).to receive(:say) }
    before { allow(OpsWorks::Deployment).to receive(:wait) }
    before { allow(OpsWorks::Stack).to receive(:all) { stacks } }

    it 'should update custom cookbooks on all stacks' do
      expect(stacks[0]).to receive(:execute_recipe).with(recipe) { deployment }
      expect(stacks[1]).to receive(:execute_recipe).with(recipe) { deployment }
      subject.exec(recipe)
    end

    it 'should optionally run on a subset of stacks' do
      expect(stacks[0]).to receive(:execute_recipe).with(recipe) { deployment }
      expect(stacks[1]).not_to receive(:execute_recipe)

      allow(subject).to receive(:options) { { stack: [stacks[0].name] } }
      subject.exec(recipe)
    end

    it 'should fail if any update fails' do
      failure = Fabricate(:deployment, status: 'failed')
      expect(stacks[0]).to receive(:execute_recipe).with(recipe) { failure }

      allow(subject).to receive(:options) { { stack: [stacks[0].name] } }
      expect { subject.exec(recipe) }.to raise_error
    end
  end
end
