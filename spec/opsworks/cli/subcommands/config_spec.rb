require 'spec_helper'

describe OpsWorks::CLI::Agent do
  context 'config' do
    let(:custom_json) { { 'env' => { 'FOO' => 'bar' } } }
    let(:json_path) { 'env.FOO' }
    let(:stack) { Fabricate(:stack, custom_json: custom_json) }
    let(:client) { double.as_null_object }

    before { allow(subject).to receive(:say) }
    before { allow(OpsWorks::Stack).to receive(:all) { [stack] } }
    before { allow(OpsWorks::Stack).to receive(:client) { client } }

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
        expect(client).to receive(:update_stack) do |hash|
          json = JSON.parse(hash[:custom_json])
          expect(json['env']['FOO']).to eq 'baz'
        end
        subject.send('config:set', json_path, 'baz')
        expect(stack.custom_json['env']['FOO']).to eq 'baz'
      end

      it 'should set the variable, if it is unset' do
        stack.custom_json = {}
        expect(client).to receive(:update_stack) do |hash|
          json = JSON.parse(hash[:custom_json])
          expect(json['env']['FOO']).to eq 'baz'
        end
        subject.send('config:set', json_path, 'baz')
        expect(stack.custom_json['env']['FOO']).to eq 'baz'
      end
    end

    describe 'config:unset' do
      it 'should unset the variable' do
        expect(client).to receive(:update_stack) do |hash|
          json = JSON.parse(hash[:custom_json])
          expect(json['env']['FOO']).to be_nil
        end
        subject.send('config:unset', json_path)
        expect(stack.custom_json['env']['FOO']).to be_nil
      end
    end
  end
end