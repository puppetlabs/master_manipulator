require 'spec_helper'

describe MasterManipulator::Service do

  let(:beaker_host)           { instance_double(Beaker::Host) }
  let(:beaker_command)        { instance_double(Beaker::Command) }
  let(:dummy_class)           { Class.new { extend MasterManipulator::Service } }
  let(:cmd_1)                 { 'resource service pe-puppetserver ensure=stopped' }
  let(:cmd_2)                 { 'resource service pe-puppetserver ensure=running' }
  let(:cmd_3)                 { 'hostname' }

  def shared_dsl_expectations
    expect(dummy_class).to receive(:on).with(beaker_host, beaker_command).twice
    expect(dummy_class).to receive(:puppet).with(cmd_1).and_return(beaker_command)
    expect(dummy_class).to receive(:puppet).with(cmd_2).and_return(beaker_command)
    expect(dummy_class).to receive(:on).with(beaker_host, cmd_3).and_return(beaker_result)
  end

  describe '.restart_puppet_server' do

    let(:beaker_result)       { x = Beaker::Result.new('host', 'cmd')
                                x.stdout = 'This is stdout'
                                x.exit_code = '0'
                                x
                              }

    it 'with correct required arguement' do
      shared_dsl_expectations
      expect(dummy_class).to receive(:curl_on).and_return(beaker_result)
      expect{dummy_class.restart_puppet_server(beaker_host)}.not_to raise_error
    end

    it 'with too many arguements' do
      expect{ dummy_class.restart_puppet_server(beaker_host, {}, 'No Bueno') }.to raise_error(ArgumentError)
    end

    it 'with no arguements' do
      expect{ dummy_class.restart_puppet_server }.to raise_error(ArgumentError)
    end

    context 'negative cases' do

      let(:beaker_result)     { x = Beaker::Result.new('host', 'cmd')
                                x.stdout = 'This is stdout'
                                x.exit_code = '7'
                                x
                              }
      let(:failed_curl_result)      { x = Beaker::Result.new('host', 'cmd')
                                      x.stdout = 'This is stdout'
                                      x.exit_code = '1'
                                      x
                                    }

      it 'puppet server never starts' do
        shared_dsl_expectations
        expect(dummy_class).to receive(:curl_on).exactly(10).times.and_return(beaker_result)
        expect{ dummy_class.restart_puppet_server(beaker_host, {:time_out => 10}) }.to raise_error(RuntimeError, "Attempted to restart 10 times, waited 5 seconds between attempts.")
      end

      it 'should fail gracefully when curl fails' do
        shared_dsl_expectations
        expect(dummy_class).to receive(:curl_on).exactly(10).times.and_return(failed_curl_result)
        expect{ dummy_class.restart_puppet_server(beaker_host, {:time_out => 10}) }.to raise_error(RuntimeError, "Attempted to restart 10 times, waited 5 seconds between attempts.")
      end

    end

  end

end
