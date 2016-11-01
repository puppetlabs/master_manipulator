require 'spec_helper'

describe MasterManipulator::Site do

  let(:dummy_class)     { Class.new { extend MasterManipulator::Site } }
  let(:cmd_one)         {'config print certname'}
  let(:host)            { instance_double(Beaker::Host) }
  let(:result)          {
                          x = Beaker::Result.new('host', 'cmd')
                          x.stdout = 'This is stdout'
                          x.exit_code = '0'
                          x
                        }
  let(:command)         { instance_double(Beaker::Command) }
  let(:manifest)        {
    pp =<<-EOS
file{ '/etc/foo/bar.baz'
  ensure  => absent,
  content => 'Important Information',
}
EOS
  }
  let(:node_def_name)   {'skeletor'}
  let(:env_name)        {'farts'}
  let(:base_path)       {'This is stdout'}

  describe '.get_manifests_path' do

    it 'with all required arguments' do
      expect(dummy_class).to receive(:on).with(host, command).and_return(result)
      expect(dummy_class).to receive(:puppet).with('config print environmentpath').and_return(command)
      r = dummy_class.get_manifests_path(host,{:env => env_name})
      expect(r).to eq("#{base_path}/#{env_name}/manifests")
    end

    it 'without env' do
      expect(dummy_class).to receive(:on).with(host, command).and_return(result)
      expect(dummy_class).to receive(:puppet).with('config print environmentpath').and_return(command)
      r = dummy_class.get_manifests_path(host)
      expect(r).to eq("#{base_path}/production/manifests")
    end

    context 'negative' do

      it 'with no arguments' do
        expect{dummy_class.get_manifests_path}.to raise_error(ArgumentError)
      end

    end

  end

  describe '.get_site_pp_path' do

    it 'with all required arguments' do
      expect(dummy_class).to receive(:on).with(host, command).and_return(result)
      expect(dummy_class).to receive(:puppet).with('config print environmentpath').and_return(command)
      r = dummy_class.get_site_pp_path(host,{:env => env_name})
      expect(r).to eq("#{base_path}/#{env_name}/manifests/site.pp")
    end

    it 'without env' do
      expect(dummy_class).to receive(:on).with(host, command).and_return(result)
      expect(dummy_class).to receive(:puppet).with('config print environmentpath').and_return(command)
      r = dummy_class.get_site_pp_path(host)
      expect(r).to eq("#{base_path}/production/manifests/site.pp")
    end

    context 'negative' do

      it 'with no arguments' do
        expect{dummy_class.get_site_pp_path}.to raise_error(ArgumentError)
      end

    end

  end

  describe '.create_site_pp' do

    it 'with all required arguments' do
      expect(dummy_class).to receive(:on).with(host, command).and_return(result)
      expect(dummy_class).to receive(:puppet).with(cmd_one).and_return(command)
      r = dummy_class.create_site_pp(host,{:manifest => manifest, :node_def_name => node_def_name})
      expect(r).to match(/node #{node_def_name} {\s*#{manifest}\s*}/m)
    end

    it 'without node_def_name' do
      expect(dummy_class).to receive(:on).with(host, command).and_return(result)
      expect(dummy_class).to receive(:puppet).with(cmd_one).and_return(command)
      r = dummy_class.create_site_pp(host,{:manifest => manifest})
      expect(r.class).to eq(String)
      expect(r).to match(/node default {\s*#{manifest}\s*}/m)
    end

    it 'without manifest' do
      expect(dummy_class).to receive(:on).with(host, command).and_return(result)
      expect(dummy_class).to receive(:puppet).with(cmd_one).and_return(command)
      r = dummy_class.create_site_pp(host,{:node_def_name => node_def_name})
      expect(r.class).to eq(String)
      expect(r).to match(/node default {*\s}/m)
    end

    context 'negative' do

      it 'with no arguments' do
        expect{dummy_class.create_site_pp}.to raise_error(ArgumentError)
      end

    end

  end

  describe '.set_perms_on_remote' do

    let(:owner) {'root'}
    let(:group) {'wheel'}
    let(:mode)  {'777'}
    let(:path)  {'/my_fun_path/totally/real/'}

    it 'with all arguments' do
      opts = {:owner => owner, :group => group}
      expect(dummy_class).to receive(:on).exactly(2).times.and_return(result)
      expect{dummy_class.set_perms_on_remote(host, path, mode, opts)}.not_to raise_error
    end

    it 'without owner' do
      opts = {:group => group}
      expect(dummy_class).to receive(:on).exactly(3).times.and_return(result)
      expect(dummy_class).to receive(:puppet).with('config print user')
      expect{dummy_class.set_perms_on_remote(host, path, mode, opts)}.not_to raise_error
    end

    it 'without group' do
      opts = {:owner => owner}
      expect(dummy_class).to receive(:on).exactly(3).times.and_return(result)
      expect(dummy_class).to receive(:puppet).with('config print group')
      expect{dummy_class.set_perms_on_remote(host, path, mode, opts)}.not_to raise_error
    end

    it 'without group or owner' do
      expect(dummy_class).to receive(:on).exactly(4).times.and_return(result)
      expect(dummy_class).to receive(:puppet).with('config print user')
      expect(dummy_class).to receive(:puppet).with('config print group')
      expect{dummy_class.set_perms_on_remote(host, path, mode)}.not_to raise_error
    end

    context 'negative' do

      it 'with no arguments' do
        expect{dummy_class.set_perms_on_remote}.to raise_error(ArgumentError)
      end

    end

  end

  describe '.inject_site_pp' do

    let(:site_pp_path)    {'/etc/puppet/fake/dir/site.pp'}

    it 'with all correct arguments' do
      expect(dummy_class).to receive(:create_remote_file)
      expect(dummy_class).to receive(:on).exactly(4).times.and_return(result)
      expect(dummy_class).to receive(:puppet).with('config print user')
      expect(dummy_class).to receive(:puppet).with('config print group')
      expect{ dummy_class.inject_site_pp(host, site_pp_path, manifest) }.not_to raise_error
    end

    context 'negative' do

      it 'with no arguments' do
        expect{ dummy_class.inject_site_pp }.to raise_error(ArgumentError)
      end

    end

  end

end
