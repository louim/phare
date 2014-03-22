require 'spec_helper'

describe Phare::Check::Rubocop do
  describe :should_run? do
    let(:check) { described_class.new('.') }
    before { expect(Phare).to receive(:system_output).with('which rubocop').and_return(which_output) }

    context 'with found rubocop command' do
      let(:which_output) { 'rubocop' }
      it { expect(check).to be_able_to_run }
    end

    context 'with unfound rubocop command' do
      let(:which_output) { '' }
      it { expect(check).to_not be_able_to_run }
    end
  end

  describe :run do
    let(:check) { described_class.new('.') }
    let(:run!) { check.run }

    context 'with available Rubocop' do
      before do
        expect(check).to receive(:should_run?).and_return(true)
        expect(Phare).to receive(:system).with(check.command)
        expect(Phare).to receive(:last_exit_status).and_return(rubocop_exit_status)
        expect(check).to receive(:print_banner)
      end

      context 'with check errors' do
        let(:rubocop_exit_status) { 0 }
        it { expect { run! }.to change { check.status }.to(0) }
      end

      context 'without check errors' do
        let(:rubocop_exit_status) { 1337 }
        before { expect(Phare).to receive(:puts).with("Something went wrong. Program exited with #{rubocop_exit_status}") }
        it { expect { run! }.to change { check.status }.to(rubocop_exit_status) }
      end
    end

    context 'with unavailable Rubocop' do
      before do
        expect(check).to receive(:should_run?).and_return(false)
        expect(Phare).to_not receive(:system).with(check.command)
        expect(check).to_not receive(:print_banner)
      end

      it { expect { run! }.to change { check.status }.to(0) }
    end
  end
end
