require 'spec_helper'

describe OpsWorks::CLI::Agent do
  let(:stacks) do
    Array.new(3) { |i| Fabricate(:stack, name: "stack-#{i}") }
  end
  before { allow(OpsWorks::Stack).to receive(:all) { stacks } }

  describe 'instances:status' do
    it 'returns the status of instances on all stacks' do
      statuses = %w(starting online setup_failed)

      stacks.zip(statuses).each do |stack, status|
        i = Fabricate(:instance, hostname: "instance-#{status}", status: status)
        expect(stack).to receive(:instances).and_return([i])
      end

      messages = [
        "stack-0\tinstance-starting\tstarting",
        "stack-1\tinstance-online\tonline",
        "stack-2\tinstance-setup_failed\tsetup_failed"
      ]

      messages.each do |m|
        expect(subject).to receive(:say).with(m).once.ordered
      end

      subject.send('instances:status')
    end

    it 'returns the status of instances on the selected stacks' do
      i = Fabricate(:instance, hostname: 'instance', status: 'online')
      expect(stacks[1]).to receive(:instances).and_return([i])
      [0, 2].each { |n| expect(stacks[n]).not_to receive(:instances) }

      expect(subject).to receive(:say).with("stack-1\tinstance\tonline")
      subject.options = { stack: [stacks[1].name] }

      subject.send('instances:status')
    end
  end

  describe 'instances:wait' do
    before do
      subject.options = { timeout: 100 }
    end

    it 'waits until all stacks settle' do
      stacks.each { |s| expect(s).to receive(:settled?).and_return(false) }
      expect(subject).to receive(:sleep) do
        stacks.each { |s| expect(s).to receive(:settled?).and_return(true) }
      end

      subject.send('instances:wait')
    end

    it 'waits until selected stacks settle' do
      expect(stacks[0]).to receive(:settled?).and_return(false)
      expect(subject).to receive(:sleep) do
        expect(stacks[0]).to receive(:settled?).and_return(true)
      end

      expect(stacks[1]).not_to receive(:settled?)
      expect(stacks[2]).not_to receive(:settled?)

      subject.options[:stack] = [stacks[0].name]

      subject.send('instances:wait')
    end

    it 'fails if the stacks never settle' do
      t = 0
      allow(subject).to receive(:sleep) do |i|
        t += i
        Timecop.freeze(t)
      end

      stacks.each { |s| allow(s).to receive(:settled?).and_return(false) }
      allow(stacks[0]).to receive(:settled?).and_return(true)

      expect { Timecop.freeze(t) { subject.send('instances:wait') } }
        .to raise_error(/did not settle: stack-1 stack-2$/i)
    end
  end

  describe 'instances:setup' do
    let(:i0) { Fabricate(:instance, hostname: 'i0', status: 'setup_failed') }
    let(:i1) { Fabricate(:instance, hostname: 'i1', status: 'online') }
    let(:i2) { Fabricate(:instance, hostname: 'i2', status: 'setup_failed') }

    before do
      allow(stacks[0]).to receive(:instances).and_return([i0])
      allow(stacks[1]).to receive(:instances).and_return([i1])
      allow(stacks[2]).to receive(:instances).and_return([i2])
    end

    it 're-runs setup on setup_failed instances across all stacks' do
      expect(stacks[0]).to receive(:create_deployment)
        .with(command: { name: 'setup' }, instance_ids: [i0.id])

      expect(stacks[1]).not_to receive(:create_deployment)

      expect(stacks[2]).to receive(:create_deployment)
        .with(command: { name: 'setup' }, instance_ids: [i2.id])

      expect(subject).to receive(:say)
        .with('Running setup on stack-0 i0')
        .once.ordered

      expect(subject).to receive(:say)
        .with('Running setup on stack-2 i2')
        .once.ordered

      subject.send('instances:setup')
    end

    it 're-runs setup on setup_failed instances across selected stacks' do
      expect(stacks[0]).not_to receive(:create_deployment)
      expect(stacks[1]).not_to receive(:create_deployment)
      expect(stacks[2]).to receive(:create_deployment)
        .with(command: { name: 'setup' }, instance_ids: [i2.id])

      expect(subject).to receive(:say)
        .with('Running setup on stack-2 i2')
        .once.ordered

      subject.options = { stack: [stacks[2].name] }

      subject.send('instances:setup')
    end
  end
end
