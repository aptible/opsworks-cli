require 'spec_helper'

describe OpsWorks::CLI::Agent do
  describe '#lockdown' do
    let(:permissions) { 2.times.map { Fabricate(:permission) } }
    let(:user) { permissions[0].user }
    let(:stack) do
      Fabricate(:stack).tap do |stack|
        allow(stack).to receive(:permissions) { permissions }
      end
    end

    before { allow(subject).to receive(:say) }
    before { allow(OpsWorks::Stack).to receive(:all) { [stack] } }
    before { allow(OpsWorks::Stack).to receive(:active) { [stack] } }

    it 'should lock down all stacks' do
      expect(permissions[0]).to receive(:update).with(ssh: false, sudo: false)
      expect(permissions[1]).to receive(:update).with(ssh: false, sudo: false)
      subject.lockdown
    end

    it 'should optionally run on a subset of stacks' do
      expect(permissions[0]).to receive(:update).with(ssh: false, sudo: false)
      expect(permissions[1]).to receive(:update).with(ssh: false, sudo: false)

      allow(subject).to receive(:options) { { stacks: [stack.name] } }
      subject.lockdown
    end
  end
end
