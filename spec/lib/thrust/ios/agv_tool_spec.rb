require 'spec_helper'

describe Thrust::IOS::AgvTool do
  let(:thrust_executor) { Thrust::FakeExecutor.new }
  let(:git) { double(Thrust::Git) }

  subject { Thrust::IOS::AgvTool.new(thrust_executor, git) }

  before do
    git.stub(:checkout_file)
  end

  describe '#change_build_number' do
    before do
      subject.change_build_number(1000, nil)
    end

    it 'instructs agvtool to change the version' do
      expect(thrust_executor.system_or_exit_history.last).to eq({
        cmd: 'cd . && agvtool new-version -all \'1000\'',
        output_file: nil
      })
    end

    it 'resets the .xcodeproj files via git' do
      expect(git).to have_received(:checkout_file).with('./*.xcodeproj')
    end

    context 'when a path to an .xcodeproj file is specified' do
      before do
        subject.change_build_number(1000, '../foo/bar.xcodeproj')
      end

      it 'cds to the parent directory' do
        expect(thrust_executor.system_or_exit_history.last).to eq({
                                                                    cmd: 'cd ../foo && agvtool new-version -all \'1000\'',
                                                                    output_file: nil
                                                                })
      end

      it 'resets the .xcodeproj files via git' do
        expect(git).to have_received(:checkout_file).with('../foo/*.xcodeproj')
      end
    end
  end
end
