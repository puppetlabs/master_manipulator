require 'spec_helper'

describe MasterManipulator::Service do

  let(:beaker_host)           { instance_double(Beaker::Host) }
  let(:beaker_command)        { instance_double(Beaker::Command) }
  let(:beaker_result)         { instance_double(Beaker::Result) }
  let(:dummy_class)           { Class.new { extend MasterManipulator::Service } }

  describe '.restart_puppet_server' do

    it 'with correct required arguement' do
      cmd_1 = 'resource service pe-puppetserver ensure=stopped'
      cmd_2 = 'resource service pe-puppetserver ensure=running'
      cmd_3 = 'hostname'

      expect(dummy_class).to receive(:on).with(beaker_host, beaker_command).and_return(beaker_result)
      expect(dummy_class).to receive(:puppet).with(cmd_1).and_return(beaker_command)
      expect(dummy_class).to receive(:puppet).with(cmd_2).and_return(beaker_command)
      expect(dummy_class).to receive(:on).with(beaker_host, cmd_3).and_return(beaker_result)
      expect(dummy_class.restart_puppet_server(beaker_host)).to eq(beaker_result)
    end

    it 'with too many arguements' do
      expect{ dummy_class.restart_puppet_server(beaker_host, {}, 'No Bueno') }.to raise_error(ArgumentError)
    end

    it 'with no arguements' do
      expect{ dummy_class.restart_puppet_server }.to raise_error(ArgumentError)
    end

  end

end
