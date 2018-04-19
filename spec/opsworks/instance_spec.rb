require 'spec_helper'

describe OpsWorks::Instance do
  context 'status' do
    STATUSES = [
      ['booting', false, false],
      ['connection_lost', true, true],
      ['online', true, false],
      ['pending', false, false],
      ['rebooting', false, false],
      ['requested', false, false],
      ['running_setup', false, false],
      ['setup_failed', true, true],
      ['shutting_down', false, false],
      ['start_failed', true, true],
      ['stop_failed', true, true],
      ['stopped', true, false],
      ['stopping', false, false],
      ['terminated', true, false],
      ['terminating', false, false]
    ].freeze

    STATUSES.each do |status, settled_expected, fatal_expected|
      context status do
        it "#settled? is #{settled_expected}" do
          i = described_class.new(nil, status: status)
          expect(i.settled?).to be(settled_expected)
        end

        it "#fatal? is #{fatal_expected}" do
          i = described_class.new(nil, status: status)
          expect(i.fatal?).to be(fatal_expected)
        end
      end
    end

    it 'has only a few defined non-fatal settled states' do
      # We use this to make sure that our test cases above are coherent.
      expect(STATUSES.select { |_, s, f| s && !f }.map(&:first))
        .to match_array(%w(online stopped terminated))
    end
  end
end
