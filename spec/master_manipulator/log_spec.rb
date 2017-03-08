require 'spec_helper'
require 'fileutils'

describe MasterManipulator::Log do

  let(:beaker_host)           { instance_double(Beaker::Host) }
  let(:dummy_class)           { Class.new { extend MasterManipulator::Log} }
#  let(:beaker_command)        { instance_double(Beaker::Command) }
  let(:log_dir)               { "/tmp/MasterManipulator_Log/#{Process.pid}/puppetlabs/puppet" }
  let(:log_dir_to_make)       { "/tmp/MasterManipulator_Log/#{Process.pid}/puppetlabs/puppetserver" }
  let(:log_file)              { "/tmp/MasterManipulator_Log/#{Process.pid}/puppetlabs/puppetserver/puppetserver.log" }
  let(:backup_log_file_base)  { "/tmp/MasterManipulator_Log/#{Process.pid}/puppetlabs/puppetserver/puppetserver.1976-07-04" }
  let(:cmd_1)                 { 'puppet config print logdir' }
  let(:cmd_test_log_file)     { "test -f #{log_file}" }
  let(:cmd_date)              { "date +%Y-%m-%d" }
  let(:cmd_test_backup_log_file_generic) { "test -f #{backup_log_file_base}.*" }
  let(:cmd_test_backup_log_file_0) { "test -f #{backup_log_file_base}.0.log" }
  let(:cmd_test_backup_log_file_1) { "test -f #{backup_log_file_base}.1.log*" }
  let(:max_trys)              { 100 }


  def shared_dsl_expectations
    log_result = Beaker::Result.new('host', 'cmd')
    log_result.stdout = log_dir
    expect(dummy_class).to receive(:on).with(beaker_host, cmd_1).and_return(log_result)

    date_result = Beaker::Result.new('host', 'cmd')
    date_result.stdout = "1976-07-04"
    expect(dummy_class).to receive(:on).with(beaker_host, cmd_date).and_return(date_result)
  end
  
#add test for if log file is missing

  context 'Normal' do 
      
    describe '.rotate_puppet_server_log' do
      it 'With correct required argument' do
        shared_dsl_expectations

        log_file_test_result = Beaker::Result.new('host', 'cmd')
        log_file_test_result.exit_code = 0
        expect(dummy_class).to receive(:on).with(beaker_host, cmd_test_log_file, :accept_all_exit_codes => true).and_return(log_file_test_result)

        backup_log_file_test_result = Beaker::Result.new('host', 'cmd')
        backup_log_file_test_result.exit_code = 1
        expect(dummy_class).to receive(:on).with(beaker_host, /#{cmd_test_backup_log_file_0}/,:accept_all_exit_codes => true ).and_return(backup_log_file_test_result)

        copy_truncate_result = Beaker::Result.new('host', 'cmd')
        copy_truncate_result.exit_code = 0
        expect(dummy_class).to receive(:on).with(beaker_host,"cp #{log_file} #{backup_log_file_base}.0.log; cat /dev/null > #{log_file}",:accept_all_exit_codes => true).and_return(copy_truncate_result)

        expect{dummy_class.rotate_puppet_server_log(beaker_host)}.not_to raise_error
      end

      it 'Backup already exists' do
        shared_dsl_expectations

        log_file_test_result = Beaker::Result.new('host', 'cmd')
        log_file_test_result.exit_code = 0
        expect(dummy_class).to receive(:on).with(beaker_host, cmd_test_log_file, :accept_all_exit_codes => true).and_return(log_file_test_result)

        backup_log_file_0_test_result = Beaker::Result.new('host', 'cmd')
        backup_log_file_0_test_result.exit_code = 0
        expect(dummy_class).to receive(:on).with(beaker_host, /#{cmd_test_backup_log_file_0}/, :accept_all_exit_codes => true ).and_return(backup_log_file_0_test_result)
      
        backup_log_file_1_test_result = Beaker::Result.new('host', 'cmd')
        backup_log_file_1_test_result.exit_code = 1
        expect(dummy_class).to receive(:on).with(beaker_host, /#{cmd_test_backup_log_file_1}/, :accept_all_exit_codes => true ).and_return(backup_log_file_1_test_result)

        copy_truncate_result = Beaker::Result.new('host', 'cmd')
        copy_truncate_result.exit_code = 0
        expect(dummy_class).to receive(:on).with(beaker_host,"cp #{log_file} #{backup_log_file_base}.1.log; cat /dev/null > #{log_file}", :accept_all_exit_codes => true).and_return(copy_truncate_result)

        expect{dummy_class.rotate_puppet_server_log(beaker_host)}.not_to raise_error
      end

      it 'With too many arguments' do
        expect{ dummy_class.rotate_puppet_server_log(beaker_host, {}, 'No Bueno') }.to raise_error(ArgumentError)
      end

      it 'With no arguments' do
        expect{ dummy_class.rotate_puppet_server_log }.to raise_error(ArgumentError)
      end
      
      it 'Log missing' do
        shared_dsl_expectations
        file_test_result = Beaker::Result.new('host', 'cmd')
        file_test_result.exit_code = 1
        expect(dummy_class).to receive(:on).with(beaker_host, cmd_test_log_file, :accept_all_exit_codes => true).and_return(file_test_result)
        expect{ dummy_class.rotate_puppet_server_log(beaker_host) }.to raise_error(RuntimeError, /Puppetserver log file missing: #{log_file}/)
      end

      it 'Exceed max rotations per minute' do
        shared_dsl_expectations

        log_file_test_result = Beaker::Result.new('host', 'cmd')
        log_file_test_result.exit_code = 0
        expect(dummy_class).to receive(:on).with(beaker_host, cmd_test_log_file, :accept_all_exit_codes => true).and_return(log_file_test_result)

        backup_log_file_test_result = Beaker::Result.new('host', 'cmd')
        backup_log_file_test_result.exit_code = 0
        expect(dummy_class).to receive(:on).with(beaker_host, /#{cmd_test_backup_log_file_generic}/, :accept_all_exit_codes => true ).exactly(max_trys).and_return(backup_log_file_test_result)
        expect{dummy_class.rotate_puppet_server_log(beaker_host)}.to raise_error(RuntimeError, /Looks like #{max_trys} puppetserver log rotations in one minute, more likely a code issue/)
      end

      it 'Copy truncate fails' do
        shared_dsl_expectations

        log_file_test_result = Beaker::Result.new('host', 'cmd')
        log_file_test_result.exit_code = 0
        expect(dummy_class).to receive(:on).with(beaker_host, cmd_test_log_file, :accept_all_exit_codes => true).and_return(log_file_test_result)

        backup_log_file_test_result = Beaker::Result.new('host', 'cmd')
        backup_log_file_test_result.exit_code = 1
        expect(dummy_class).to receive(:on).with(beaker_host, /#{cmd_test_backup_log_file_0}/, :accept_all_exit_codes => true ).and_return(backup_log_file_test_result)

        copy_truncate_result = Beaker::Result.new('host', 'cmd')
        copy_truncate_result.exit_code = 1
        expect(dummy_class).to receive(:on).with(beaker_host,"cp #{log_file} #{backup_log_file_base}.0.log; cat /dev/null > #{log_file}", :accept_all_exit_codes => true).and_return(copy_truncate_result)

        expect{dummy_class.rotate_puppet_server_log(beaker_host)}.to raise_error(RuntimeError, /The copy truncate operation failed: cp #{log_file} #{backup_log_file_base}.0.log; cat \/dev\/null > #{log_file}/)

      end
    end
  end
end
