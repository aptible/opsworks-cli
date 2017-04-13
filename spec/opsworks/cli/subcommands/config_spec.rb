require 'spec_helper'

describe OpsWorks::CLI::Agent do
  context 'config' do
    let(:custom_json) { { 'env' => { 'FOO' => 'bar' } } }
    let(:json_path) { 'env.FOO' }
    let(:stack) { Fabricate(:stack, custom_json: custom_json) }

    before { allow(subject).to receive(:say) }
    before { allow(subject).to receive(:parse_stacks).and_return([stack]) }

    describe 'config:get' do
      it 'should print the variable from the stack custom JSON' do
        expect(subject).to receive(:print_table) do |table|
          expect(table).to eq [[stack.name, 'bar']]
        end
        subject.send('config:get', json_path)
      end

      it 'should print (null) if the variable is unset' do
        stack.custom_json = {}
        expect(subject).to receive(:print_table) do |table|
          expect(table).to eq [[stack.name, '(null)']]
        end
        subject.send('config:get', json_path)
      end
    end

    describe 'config:set' do
      it 'should reset the variable, if it is already set' do
        expect(stack.client).to receive(:update_stack) do |hash|
          json = JSON.parse(hash[:custom_json])
          expect(json['env']['FOO']).to eq 'baz'
        end
        subject.send('config:set', json_path, 'baz')
        expect(stack.custom_json['env']['FOO']).to eq 'baz'
      end

      it 'should work with deep nested hashes' do
        stack.custom_json = { 'app' => { 'var' => 'value' } }
        expect(stack.client).to receive(:update_stack) do |hash|
          json = JSON.parse(hash[:custom_json])
          expect(json['app']['env']['FOO']).to eq 'baz'
        end
        subject.send('config:set', 'app.env.FOO', 'baz')
        expect(stack.custom_json['app']['env']['FOO']).to eq 'baz'
      end

      it 'should set the variable, if it is unset' do
        stack.custom_json = {}
        expect(stack.client).to receive(:update_stack) do |hash|
          json = JSON.parse(hash[:custom_json])
          expect(json['env']['FOO']).to eq 'baz'
        end
        subject.send('config:set', json_path, 'baz')
        expect(stack.custom_json['env']['FOO']).to eq 'baz'
      end

      it 'should leave other variables alone' do
        stack.custom_json['other'] = 'something'
        expect(stack.client).to receive(:update_stack) do |hash|
          json = JSON.parse(hash[:custom_json])
          expect(json['env']['FOO']).to eq 'baz'
          expect(json['other']).to eq 'something'
        end
        subject.send('config:set', json_path, 'baz')
        expect(stack.custom_json['env']['FOO']).to eq 'baz'
        expect(stack.custom_json['other']).to eq 'something'
      end

      it 'should typecast Boolean values' do
        stack.custom_json = {}
        expect(stack.client).to receive(:update_stack) do |hash|
          json = JSON.parse(hash[:custom_json])
          expect(json['env']['FOO']).to eq true
        end
        subject.send('config:set', json_path, 'true')
        expect(stack.custom_json['env']['FOO']).to eq true
      end
    end

    describe 'config:unset' do
      it 'should unset the variable' do
        expect(stack.client).to receive(:update_stack) do |hash|
          json = JSON.parse(hash[:custom_json])
          expect(json['env'].keys).not_to include('FOO')
        end
        subject.send('config:unset', json_path)
        expect(stack.custom_json['env'].keys).not_to include('FOO')
      end

      it 'should leave other variables alone' do
        stack.custom_json['env']['OTHER'] = 'something'
        expect(stack.client).to receive(:update_stack) do |hash|
          json = JSON.parse(hash[:custom_json])
          expect(json['env'].keys).not_to include('FOO')
        end
        subject.send('config:unset', json_path)
        expect(stack.custom_json['env']).to eq('OTHER' => 'something')
      end

      it 'should work even with nil values' do
        stack.custom_json['env'] = { 'FOO' => nil }
        expect(stack.client).to receive(:update_stack) do |hash|
          json = JSON.parse(hash[:custom_json])
          expect(json['env'].keys).not_to include('FOO')
        end
        subject.send('config:unset', json_path)
        expect(stack.custom_json['env'].keys).not_to include('FOO')
      end
    end
  end
end
