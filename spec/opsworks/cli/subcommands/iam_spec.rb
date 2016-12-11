require 'spec_helper'

describe OpsWorks::CLI::Agent do
  context 'iam' do
    let(:permissions) { Array.new(2) { Fabricate(:permission) } }
    let(:user) { permissions[0].user }

    before { allow(subject).to receive(:say) }
    before { allow(OpsWorks::Stack).to receive(:all) { stacks } }
    before { allow(OpsWorks::Stack).to receive(:active) { stacks } }

    describe 'iam:allow' do
      let(:stacks) do
        Array.new(2) do |i|
          Fabricate(:stack).tap do |stack|
            allow(stack).to receive(:find_permission_by_user) { permissions[i] }
          end
        end
      end

      it 'should update all matching permissions' do
        expect(permissions[0]).to receive(:update)
        expect(permissions[1]).to receive(:update)
        subject.send('iam:allow', user)
      end

      it 'should optionally run on a subset of stacks' do
        expect(permissions[0]).to receive(:update)
        expect(permissions[1]).not_to receive(:update)

        allow(subject).to receive(:options) { { stack: [stacks[0].name] } }
        subject.send('iam:allow', user)
      end

      it 'should accept :ssh and :sudo options' do
        expect(permissions[0]).to receive(:update).with(ssh: true, sudo: false)

        allow(subject).to receive(:options) do
          { stack: [stacks[0].name], ssh: true, sudo: false }
        end
        subject.send('iam:allow', user)
      end
    end

    describe 'iam:lockdown' do
      let(:stack) do
        Fabricate(:stack).tap do |stack|
          allow(stack).to receive(:permissions) { permissions }
        end
      end
      let(:stacks) { [stack] }

      it 'should lock down all stacks' do
        expect(permissions[0]).to receive(:update).with(ssh: false, sudo: false)
        expect(permissions[1]).to receive(:update).with(ssh: false, sudo: false)
        subject.send('iam:lockdown')
      end

      it 'should optionally run on a subset of stacks' do
        expect(permissions[0]).to receive(:update).with(ssh: false, sudo: false)
        expect(permissions[1]).to receive(:update).with(ssh: false, sudo: false)

        allow(subject).to receive(:options) { { stacks: [stack.name] } }
        subject.send('iam:lockdown')
      end
    end
  end
end
