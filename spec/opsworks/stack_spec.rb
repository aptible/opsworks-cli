require 'spec_helper'

describe OpsWorks::Stack do
  describe '#settled?' do
    it 'makes a new API call' do
      client = Aws::OpsWorks::Client.new(
        stub_responses: {
          describe_instances: [
            { instances: [{ instance_id: 'a', status: 'starting' }] },
            { instances: [{ instance_id: 'a', status: 'online' }] },
            { instances: [{ instance_id: 'b', status: 'stopping' }] }
          ]
        }
      )

      subject = described_class.new(client, id: '123')

      expect(client).to receive(:describe_instances)
        .with(stack_id: '123')
        .exactly(3).times
        .and_call_original

      expect(subject).not_to be_settled
      expect(subject).to be_settled
      expect(subject).not_to be_settled
    end

    it 'returns true if all instances have settled' do
      client = Aws::OpsWorks::Client.new(
        stub_responses: {
          describe_instances: {
            instances: [
              { instance_id: 'a', status: 'online' },
              { instance_id: 'b', status: 'stopped' }
            ]
          }
        }
      )

      expect(described_class.new(client, id: '123')).to be_settled
    end

    it 'returns false if any instances has not settled' do
      client = Aws::OpsWorks::Client.new(
        stub_responses: {
          describe_instances: {
            instances: [
              { instance_id: 'a', status: 'online' },
              { instance_id: 'b', status: 'stopping' }
            ]
          }
        }
      )

      expect(described_class.new(client, id: '123')).not_to be_settled
    end

    it 'fails if any instance will not settle' do
      client = Aws::OpsWorks::Client.new(
        stub_responses: {
          describe_instances: {
            instances: [
              { instance_id: 'a', status: 'online' },
              { instance_id: 'b', status: 'setup_failed', hostname: 'bar' }
            ]
          }
        }
      )

      e = OpsWorks::Errors::StackInFatalState

      expect { described_class.new(client, id: '123', name: 'foo').settled? }
        .to raise_error(e, /fatal.*foo.*bar/i)
    end
  end
end
