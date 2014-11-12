require 'spec_helper'

describe OpsWorks::CLI::Agent do
  describe '#allow' do
    let(:permissions) { 2.times.map { Fabricate(:permission) } }
    let(:user) { permissions[0].user }
    let(:stacks) do
      2.times.map do |i|
        Fabricate(:stack).tap do |stack|
          allow(stack).to receive(:find_permission_by_user) { permissions[i] }
        end
      end
    end

    before { allow(subject).to receive(:say) }
    before { allow(OpsWorks::Stack).to receive(:all) { stacks } }
    before { allow(OpsWorks::Stack).to receive(:active) { stacks } }

    it 'should update all matching permissions' do
      expect(permissions[0]).to receive(:update)
      expect(permissions[1]).to receive(:update)
      subject.allow(user)
    end

    it 'should optionally run on a subset of stacks' do
      expect(permissions[0]).to receive(:update)
      expect(permissions[1]).not_to receive(:update)

      allow(subject).to receive(:options) { { stack: [stacks[0].name] } }
      subject.allow(user)
    end

    it 'should accept :ssh and :sudo options' do
      expect(permissions[0]).to receive(:update).with(ssh: true, sudo: false)

      allow(subject).to receive(:options) do
        { stack: [stacks[0].name], ssh: true, sudo: false }
      end
      subject.allow(user)
    end
  end
end
