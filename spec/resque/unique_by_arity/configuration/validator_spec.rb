# frozen_string_literal: true

require 'spec_helper'

describe Resque::UniqueByArity::Configuration::Validator do
  describe '#log_warnings' do
    context 'when no configuration is set' do
      let(:config) do
        Resque::UniqueByArity::Configuration.new(
          unique_in_queue: false,
          unique_at_runtime: false,
          unique_across_queues: false
        )
      end

      subject { described_class.new(config) }

      before do
        allow(Resque::UniqueByArity).to receive(:log)

        subject.log_warnings
      end

      it { expect(Resque::UniqueByArity).not_to have_received(:log) }
    end

    context 'when runtime_requeue_interval is set' do
      let(:config) do
        Resque::UniqueByArity::Configuration.new(
          runtime_requeue_interval: 100
        )
      end

      subject { described_class.new(config) }

      before do
        allow(Resque::UniqueByArity).to receive(:log)

        subject.log_warnings
      end

      it { expect(Resque::UniqueByArity).to have_received(:log) }
    end

    context 'when runtime_lock_timeout is set' do
      let(:config) do
        Resque::UniqueByArity::Configuration.new(
          runtime_lock_timeout: 100
        )
      end

      subject { described_class.new(config) }

      before do
        allow(Resque::UniqueByArity).to receive(:log)

        subject.log_warnings
      end

      it { expect(Resque::UniqueByArity).to have_received(:log) }
    end

    context 'when arity_for_uniqueness is set' do
      let(:config) do
        Resque::UniqueByArity::Configuration.new(
          arity_for_uniqueness: 100
        )
      end

      subject { described_class.new(config) }

      before do
        allow(Resque::UniqueByArity).to receive(:log)

        subject.log_warnings
      end

      it { expect(Resque::UniqueByArity).to have_received(:log) }
    end
  end
end
