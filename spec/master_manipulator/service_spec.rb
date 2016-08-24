require 'spec_helper'

describe MasterManipulator::Service do

  let(:beaker_host)           { instance_double(Beaker::Host) }
  let(:beaker_command)        { instance_double(Beaker::Command) }
  let(:dummy_class)           { Class.new { extend MasterManipulator::Service } }
  let(:cmd_1)                 { 'resource service pe-puppetserver ensure=stopped' }
  let(:cmd_2)                 { 'resource service pe-puppetserver ensure=running' }
  let(:cmd_3)                 { 'hostname' }
  let(:successful_stdout)     { IO.read(File.expand_path('spec/files/success_body.txt')) }
  let(:failure_stdout)        { IO.read(File.expand_path('spec/files/failure.txt')) }

  def shared_dsl_expectations
    expect(dummy_class).to receive(:on).with(beaker_host, beaker_command).twice
    expect(dummy_class).to receive(:puppet).with(cmd_1).and_return(beaker_command)
    expect(dummy_class).to receive(:puppet).with(cmd_2).and_return(beaker_command)
    expect(beaker_host).to receive(:hostname).and_return('foobar.puppetlabs.net')
  end

  context 'compatibility with 3.8' do

    def expect_pe_version
      result = Beaker::Result.new('host', 'cmd')
      result.stdout = "3.8.8\n"

      expect(dummy_class).to receive(:on).with(beaker_host, 'test -f /opt/puppet/pe_version', :acceptable_exit_codes => [0,1]).and_return(beaker_result)
      expect(dummy_class).to receive(:on).with(beaker_host, 'cat /opt/puppet/pe_version').and_return(result)
    end

    describe '.restart_puppet_server' do

      let(:beaker_result)       { x = Beaker::Result.new('host', 'cmd')
      x.stdout = successful_stdout
      x.exit_code = 0
      x
      }

      it 'with correct required arguement' do
        expect_pe_version
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

        let(:beaker_no_connection_result)     { x = Beaker::Result.new('host', 'cmd')
        x.stdout = failure_stdout
        x.exit_code = '7'
        x
        }
        let(:failed_curl_result)      { x = Beaker::Result.new('host', 'cmd')
        x.stdout = failure_stdout
        x.exit_code = '1'
        x
        }

        it 'puppet server never starts' do
          expect_pe_version
          shared_dsl_expectations
          expect(dummy_class).to receive(:curl_on).exactly(3).times.and_return(beaker_no_connection_result)
          expect{ dummy_class.restart_puppet_server(beaker_host, {:wait_cycles => 3}) }.to raise_error(RuntimeError, /Attempted to restart 3 times, waited .* seconds total/)
        end

        it 'should fail gracefully when curl fails' do
          expect_pe_version
          shared_dsl_expectations
          expect(dummy_class).to receive(:curl_on).exactly(3).times.and_return(failed_curl_result)
          expect{ dummy_class.restart_puppet_server(beaker_host, {:wait_cycles => 3}) }.to raise_error(RuntimeError, /Attempted to restart 3 times, waited .* seconds total/)
        end

      end

    end
  end

  context 'compatibility with Ankeny' do

    def expect_pe_version
      result = Beaker::Result.new('host', 'cmd')
      result.stdout = "2015.3.8-3-4-sf587441647\n"

      failed_result = Beaker::Result.new('host', 'cmd')
      failed_result.exit_code = 1

      expect(dummy_class).to receive(:on).with(beaker_host, 'test -f /opt/puppet/pe_version', :acceptable_exit_codes => [0,1]).and_return(failed_result)
      expect(dummy_class).to receive(:on).with(beaker_host, 'test -f /opt/puppetlabs/server/pe_version', :acceptable_exit_codes => [0,1]).and_return(beaker_result)
      expect(dummy_class).to receive(:on).with(beaker_host, 'cat /opt/puppetlabs/server/pe_version').and_return(result)
    end

    describe '.restart_puppet_server' do

      let(:beaker_result)       { x = Beaker::Result.new('host', 'cmd')
                                  x.stdout = successful_stdout
                                  x.exit_code = 0
                                  x
                                }

      it 'with correct required arguement' do
        expect_pe_version
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

        let(:beaker_no_connection_result)     { x = Beaker::Result.new('host', 'cmd')
                                                x.stdout = failure_stdout
                                                x.exit_code = '7'
                                                x
        }
        let(:failed_curl_result)      { x = Beaker::Result.new('host', 'cmd')
                                        x.stdout = failure_stdout
                                        x.exit_code = '1'
                                        x
        }
        let(:failed_state)      { x = Beaker::Result.new('host', 'cmd')
                                        x.stdout = failure_stdout
                                        x.exit_code = '0'
                                        x
        }

        it 'puppet server never starts' do
          expect_pe_version
          shared_dsl_expectations
          expect(dummy_class).to receive(:curl_on).exactly(3).times.and_return(beaker_no_connection_result)
          expect{ dummy_class.restart_puppet_server(beaker_host, {:wait_cycles => 3}) }.to raise_error(RuntimeError, /Attempted to restart 3 times, waited .* seconds total/)
        end

        it 'should fail gracefully when curl fails' do
          expect_pe_version
          shared_dsl_expectations
          expect(dummy_class).to receive(:curl_on).exactly(3).times.and_return(failed_curl_result)
          expect{ dummy_class.restart_puppet_server(beaker_host, {:wait_cycles => 3}) }.to raise_error(RuntimeError, /Attempted to restart 3 times, waited .* seconds total/)
        end

        it 'should report the service that is not running' do
          expect_pe_version
          shared_dsl_expectations
          expect(dummy_class).to receive(:curl_on).exactly(3).times.and_return(failed_state)
          expect{ dummy_class.restart_puppet_server(beaker_host, {:wait_cycles => 3}) }.to raise_error(RuntimeError, /'pe-master' state: foo/)
        end

      end

    end
  end

end
