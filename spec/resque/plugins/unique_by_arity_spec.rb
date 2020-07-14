require 'spec_helper'

RSpec.describe Resque::Plugins::UniqueByArity do
  subject { instance }

  let(:instance) do
    Class.new do
      def self.to_s
        'RealFake'
      end

      def self.perform(_req, _opts = {})
        # Does something
      end
      include Resque::Plugins::UniqueByArity.new(
        arity_for_uniqueness: 1,
        unique_at_runtime: true,
        unique_in_queue: true
      )
    end
  end

  let(:opts) { {} }
  let(:args) { [1, opts] }

  context '.redis_unique_hash' do
    context 'with id 1' do
      it "gives ['ef0f8a28f2c84e48211489121112e67f', [1]]" do
        expect(subject.redis_unique_hash(class: subject.to_s, args: args)).to eq ['ef0f8a28f2c84e48211489121112e67f', [1]]
      end
    end
  end

  context '.unique_in_queue_redis_key_prefix' do
    it 'gives unique_job:RealFake' do
      expect(subject.unique_in_queue_redis_key_prefix).to eq 'unique_job:RealFake'
    end
  end

  context '.unique_in_queue_key_namespace' do
    context 'with bogus queue' do
      it 'gives r-uiq:queue:bogus:job' do
        expect(subject.unique_in_queue_key_namespace('bogus')).to eq 'r-uiq:queue:bogus:job'
      end
    end
  end

  context '.unique_in_queue_redis_key' do
    context 'with bogus queue' do
      it 'gives r-uiq:queue:bogus:job:unique_job:RealFake' do
        expect(subject.unique_in_queue_redis_key('bogus', class: subject.to_s, args: args)).to eq 'r-uiq:queue:bogus:job:unique_job:RealFake'
      end
    end
    context 'when custom unique_at_runtime_key_base' do
      let(:instance) do
        Class.new do
          def self.to_s
            'RealFake'
          end

          def self.perform(req1, _opts = {})
            # Does something
          end
          include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 0,
              unique_at_runtime: true,
              unique_in_queue: true,
              unique_in_queue_key_base: 'defenestrate'
          )
        end
      end
      let(:args) { [opts] }

      it 'gives defenestrate:queue:bogus:job:unique_job:RealFake' do
        expect(subject.unique_in_queue_redis_key('bogus', class: subject.to_s, args: args)).to eq 'defenestrate:queue:bogus:job:unique_job:RealFake'
      end
    end
    context 'when perform has no required args' do
      let(:instance) do
        Class.new do
          def self.to_s
            'RealFake'
          end

          def self.perform(_opts = {})
            # Does something
          end
          include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 0,
              unique_at_runtime: true,
              unique_in_queue: true,
              unique_in_queue_key_base: 'defenestrate'
          )
        end
      end
      let(:args) { [opts] }

      it 'gives defenestrate:queue:bogus:job:unique_job:RealFake' do
        expect(subject.unique_in_queue_redis_key('bogus', class: subject.to_s, args: args)).to eq 'defenestrate:queue:bogus:job:unique_job:RealFake'
      end
    end
  end

  context '.runtime_key_namespace' do
    it 'gives r-uar:RealFake' do
      expect(subject.runtime_key_namespace).to eq 'r-uar:RealFake'
    end
  end

  context '.unique_at_runtime_redis_key' do
    it 'gives ef0f8a28f2c84e48211489121112e67f' do
      expect(subject.unique_at_runtime_redis_key(*args)).to eq 'ef0f8a28f2c84e48211489121112e67f'
    end
    context 'when perform has no required args' do
      let(:instance) do
        Class.new do
          def self.to_s
            'RealFake'
          end

          def self.perform(_opts = {})
            # Does something
          end
          include Resque::Plugins::UniqueByArity.new(
            arity_for_uniqueness: 0,
            unique_at_runtime: true,
            unique_in_queue: true
          )
        end
      end
      let(:args) { [opts] }

      it 'gives b7784ea79e21dc5d1a2fab675a505d53' do
        expect(subject.unique_at_runtime_redis_key(*args)).to eq 'b7784ea79e21dc5d1a2fab675a505d53'
      end
    end
    context 'when perform has required args, but arity is 0' do
      let(:instance) do
        Class.new do
          def self.to_s
            'RealFake'
          end

          def self.perform(req1, _opts = {})
            # Does something
          end
          include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 0,
              unique_at_runtime: true,
              unique_in_queue: true
          )
        end
      end
      let(:args) { [opts] }

      it 'gives b7784ea79e21dc5d1a2fab675a505d53' do
        expect(subject.unique_at_runtime_redis_key(*args)).to eq 'b7784ea79e21dc5d1a2fab675a505d53'
      end
    end
    context 'when custom unique_at_runtime_key_base' do
      let(:instance) do
        Class.new do
          def self.to_s
            'RealFake'
          end

          def self.perform(req1, _opts = {})
            # Does something
          end
          include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 0,
              unique_at_runtime: true,
              unique_in_queue: true,
              unique_at_runtime_key_base: 'defenestrate'
          )
        end
      end
      let(:args) { [opts] }

      it 'gives b7784ea79e21dc5d1a2fab675a505d53' do
        expect(subject.unique_at_runtime_redis_key(*args)).to eq 'b7784ea79e21dc5d1a2fab675a505d53'
      end

      it 'gives b7784ea79e21dc5d1a2fab675a505d53' do
        expect(subject.unique_at_runtime_redis_key(*args)).to eq 'b7784ea79e21dc5d1a2fab675a505d53'
      end
    end
  end

  context 'arity_for_uniqueness' do
    context 'arity_validation is nil' do
      let(:arity_validation) { nil }

      context 'no required params, arity high' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform(_opts = {})
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 2,
              arity_validation: nil,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [opts] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'does not log' do
            expect(Resque::UniqueByArity).not_to receive(:log)
            block_is_expected.not_to raise_error
          end
        end
      end

      context 'not enough required params, arity high' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform(_req, _opts = {})
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 2,
              arity_validation: nil,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [1, opts] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'does not log' do
            expect(Resque::UniqueByArity).not_to receive(:log)
            block_is_expected.not_to raise_error
          end
        end
      end

      context 'no params, arity zero' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 0,
              arity_validation: nil,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'does not log' do
            expect(Resque::UniqueByArity).not_to receive(:log)
            block_is_expected.not_to raise_error
          end
        end
      end
    end

    context 'arity_validation is false' do
      let(:arity_validation) { false }

      context 'no required params, arity high' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform(_opts = {})
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 2,
              arity_validation: nil,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [opts] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'does not log' do
            expect(Resque::UniqueByArity).not_to receive(:log)
            block_is_expected.not_to raise_error
          end
        end
      end

      context 'not enough required params, arity high' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform(_req, _opts = {})
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 2,
              arity_validation: nil,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [1, opts] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'does not log' do
            expect(Resque::UniqueByArity).not_to receive(:log)
            block_is_expected.not_to raise_error
          end
        end
      end

      context 'no params, arity zero' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 0,
              arity_validation: nil,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'does not log' do
            expect(Resque::UniqueByArity).not_to receive(:log)
            block_is_expected.not_to raise_error
          end
        end
      end
    end

    context 'arity_validation is :warning' do
      let(:arity_validation) { :warning }

      context 'no required params, arity high' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform(_opts = {})
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 2,
              arity_validation: :warning,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [opts] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'logs' do
            expect(Resque::UniqueByArity).to receive(:log).with(ColorizedString['RealFake.perform has arity of -1 which will not work with arity_for_uniqueness of 2'].red, anything)
            block_is_expected.not_to raise_error
          end
        end
      end

      context 'not enough required params, arity high' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform(_req, _opts = {})
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 2,
              arity_validation: :warning,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [1, opts] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'logs' do
            expect(Resque::UniqueByArity).to receive(:log).with(ColorizedString['RealFake.perform has the following required parameters: [:_req], which is not enough to satisfy the configured arity_for_uniqueness of 2'].red, anything)
            block_is_expected.not_to raise_error
          end
        end
      end

      context 'no params, arity zero' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 0,
              arity_validation: :warning,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'does not log' do
            expect(Resque::UniqueByArity).not_to receive(:log)
            block_is_expected.not_to raise_error
          end
        end
      end
    end

    context 'arity_validation is :error' do
      let(:arity_validation) { :error }

      context 'no required params, arity high' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform(_opts = {})
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 2,
              arity_validation: :error,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [opts] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'does not log, raises error' do
            expect(Resque::UniqueByArity).not_to receive(:log)
            block_is_expected.to raise_error ArgumentError, 'RealFake.perform has arity of -1 which will not work with arity_for_uniqueness of 2'
          end
        end
      end

      context 'not enough required params, arity high' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform(_req, _opts = {})
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 2,
              arity_validation: :error,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [1, opts] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'does not log, raises error' do
            expect(Resque::UniqueByArity).not_to receive(:log)
            block_is_expected.to raise_error ArgumentError, 'RealFake.perform has the following required parameters: [:_req], which is not enough to satisfy the configured arity_for_uniqueness of 2'
          end
        end
      end

      context 'no params, arity zero' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 0,
              arity_validation: :error,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'does not log' do
            expect(Resque::UniqueByArity).not_to receive(:log)
            block_is_expected.not_to raise_error
          end
        end
      end
    end

    context 'arity_validation is an error class' do
      let(:arity_validation) { RuntimeError }

      context 'no required params, arity high' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform(_opts = {})
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 2,
              arity_validation: RuntimeError,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [opts] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'does not log, raises error' do
            expect(Resque::UniqueByArity).not_to receive(:log)
            block_is_expected.to raise_error RuntimeError, 'RealFake.perform has arity of -1 which will not work with arity_for_uniqueness of 2'
          end
        end
      end

      context 'not enough required params, arity high' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform(_req, _opts = {})
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 2,
              arity_validation: RuntimeError,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [1, opts] }

        context 'validation' do
          subject { instance.perform(*args) }

          it 'does not log, raises error' do
            expect(Resque::UniqueByArity).not_to receive(:log)
            block_is_expected.to raise_error RuntimeError, 'RealFake.perform has the following required parameters: [:_req], which is not enough to satisfy the configured arity_for_uniqueness of 2'
          end
        end
      end

      context 'no params, arity zero' do
        subject { instance }

        let(:instance) do
          Class.new do
            def self.to_s
              'RealFake'
            end

            def self.perform
              # Does something
            end
            include Resque::Plugins::UniqueByArity.new(
              arity_for_uniqueness: 0,
              arity_validation: RuntimeError,
              unique_at_runtime: true,
              unique_in_queue: true
            )
          end
        end

        let(:args) { [] }

        it 'passes validation' do
          expect(Resque::UniqueByArity).not_to receive(:log)
          expect { subject.perform(*args) }.not_to raise_error
        end
      end
    end
  end

  context 'module included at top of class definition' do
    subject { instance.perform(*args) }

    let(:instance) do
      Class.new do
        include Resque::Plugins::UniqueByArity.new(
          arity_for_uniqueness: 0,
          arity_validation: :warning,
          unique_at_runtime: true,
          unique_in_queue: true
        )
        def self.to_s
          'RealFake'
        end

        def self.perform
          # Does something
        end
      end
    end

    let(:args) { [] }

    it 'does not work' do
      expect(Resque::UniqueByArity).not_to receive(:log)
      block_is_expected.to raise_error NameError, /undefined method `perform' for class/
    end
  end

  describe 'method arity' do
    context 'only required parameters' do
      subject { instance }

      let(:instance) do
        Class.new do
          def self.to_s
            'RealFake'
          end

          def self.perform(_req1, _req2, _req3, _req4)
            # Does something
          end
          include Resque::Plugins::UniqueByArity.new(
            arity_for_uniqueness: 1,
            unique_at_runtime: true,
            unique_in_queue: true
          )
        end
      end

      it 'is positive' do
        expect(subject.method(:perform).arity).to eq(4)
      end
    end
  end
end
