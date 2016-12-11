require 'spec_helper'

describe OpsWorks::CLI::Agent do
  context 'recipes' do
    let(:recipe) { 'hotpockets::install' }
    let(:stacks) { Array.new(2) { Fabricate(:stack) } }

    before { allow(subject).to receive(:say) }
    before { allow(OpsWorks::Deployment).to receive(:wait) }
    before { allow(OpsWorks::Stack).to receive(:all) { stacks } }
    before { allow(OpsWorks::Stack).to receive(:active) { stacks } }

    describe 'recipes:run' do
      let(:success) { Fabricate(:deployment, status: 'successful') }
      let(:failure) { Fabricate(:deployment, status: 'failed') }

      it 'should update custom cookbooks on all stacks' do
        expect(stacks[0]).to receive(:execute_recipe).with(recipe) { success }
        expect(stacks[1]).to receive(:execute_recipe).with(recipe) { success }
        subject.send('recipes:run', recipe)
      end

      it 'should optionally run on a subset of stacks' do
        expect(stacks[0]).to receive(:execute_recipe).with(recipe) { success }
        expect(stacks[1]).not_to receive(:execute_recipe)

        allow(subject).to receive(:options) { { stack: [stacks[0].name] } }
        subject.send('recipes:run', recipe)
      end

      it 'should fail if any update fails' do
        expect(stacks[0]).to receive(:execute_recipe).with(recipe) { failure }

        allow(subject).to receive(:options) { { stack: [stacks[0].name] } }
        expect { subject.send('recipes:run', recipe) }.to raise_error
      end
    end
  end
end
