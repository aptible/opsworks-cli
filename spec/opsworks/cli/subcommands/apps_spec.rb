require 'spec_helper'

describe OpsWorks::CLI::Agent do
  context 'apps' do
    let(:app_name) { 'aptible' }
    let(:stacks) { 2.times.map { Fabricate(:stack) } }

    before { allow(subject).to receive(:say) }
    before { allow(OpsWorks::Deployment).to receive(:wait) }
    before { allow(OpsWorks::Stack).to receive(:all) { stacks } }
    before { allow(OpsWorks::Stack).to receive(:active) { stacks } }

    describe 'apps:deploy' do
      let(:app) { Fabricate(:app, name: app_name) }
      let(:success) { Fabricate(:deployment, status: 'successful') }
      let(:failure) { Fabricate(:deployment, status: 'failed') }

      before do
        stacks.each { |stack| allow(stack).to receive(:apps) { [app] } }
      end

      it 'should update custom cookbooks on all stacks' do
        expect(stacks[0]).to receive(:deploy_app).with(app, anything) { success }
        expect(stacks[1]).to receive(:deploy_app).with(app, anything) { success }
        subject.send('apps:deploy', app_name)
      end

      it 'should not fail if some stacks are inactive' do
        allow(OpsWorks::Stack).to receive(:active) { [stacks[0]] }
        expect(stacks[0]).to receive(:deploy_app).with(app, anything) { success }
        expect(stacks[1]).not_to receive(:deploy_app)
        subject.send('apps:deploy', app_name)
      end

      it 'should optionally run on a subset of stacks' do
        expect(stacks[0]).to receive(:deploy_app).with(app, anything) { success }
        expect(stacks[1]).not_to receive(:deploy_app)

        allow(subject).to receive(:options) { { stack: [stacks[0].name] } }
        subject.send('apps:deploy', app_name)
      end

      it 'should optionally run migrations' do
        expect(stacks[0]).to receive(:deploy_app).with(app, {'migrate' => ['true']}) { success }
        expect(stacks[1]).to receive(:deploy_app).with(app, {'migrate' => ['true']}) { success }

        allow(subject).to receive(:options) { { migrate: true } }
        subject.send('apps:deploy', app_name)
      end

      it 'should not fail if a stack does not have the app' do
        allow(stacks[0]).to receive(:apps) { [] }
        expect(stacks[1]).to receive(:deploy_app).with(app, anything) { success }
        expect { subject.send('apps:deploy', app_name) }.not_to raise_error
      end

      it 'should fail if any update fails' do
        expect(stacks[0]).to receive(:deploy_app).with(app, anything) { failure }

        allow(subject).to receive(:options) { { stack: [stacks[0].name] } }
        expect { subject.send('apps:deploy', app_name) }.to raise_error
      end
    end

    describe 'apps:create' do
      # TODO: Figure out why Thor doesn't populate options from defaults
      # when methods are invoked directly
      let(:options) { { type: 'other' } }

      before do
        stacks.each { |stack| allow(stack).to receive(:apps) { [] } }
      end

      it 'should fail with a helpful error on unsupported type' do
        options.merge!(type: 'foobar')
        allow(subject).to receive(:options) { options }
        expect { subject.send('apps:create', app_name) }.to raise_error
      end

      xit 'should accept a Git URL'

      it 'should create an app' do
        allow(subject).to receive(:options) { options }
        expect(stacks[0]).to receive(:create_app).with(app_name, options)
        expect(stacks[1]).to receive(:create_app).with(app_name, options)
        subject.send('apps:create', app_name)
      end

      it 'should accept a different shortname' do
        options.merge!(shortname: 'foobar')
        allow(subject).to receive(:options) { options }
        expect(stacks[0]).to receive(:create_app).with(app_name, options)
        expect(stacks[1]).to receive(:create_app).with(app_name, options)
        subject.send('apps:create', app_name)
      end
    end
  end
end
