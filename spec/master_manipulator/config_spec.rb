require 'spec_helper'

describe MasterManipulator::Config do

  let(:master)        { instance_double(Beaker::Host) }
  let(:puppet)        { instance_double(Beaker::Command) }
  let(:result)        { instance_double(Beaker::Result) }
  let(:dummy_class)   { Class.new { extend MasterManipulator::Config } }

  describe '.disable_node_classifier' do

    it 'with correct argument' do
      cmd = 'config set node_terminus plain --section master'
      expect(dummy_class).to receive(:on).with(master, puppet).and_return(result)
      expect(dummy_class).to receive(:puppet).with(cmd).and_return(puppet)
      expect(dummy_class.disable_node_classifier(master)).to eq(result)
    end

    it 'with too many arguments' do
      expect{ dummy_class.disable_node_classifier(master, 'No Bueno') }.to raise_error(ArgumentError)
    end

    it 'with no arguments' do
      expect{ dummy_class.disable_node_classifier }.to raise_error(ArgumentError)
    end

  end

  describe '.disable_env_cache' do

    it 'with correct arguments' do
      cmd = 'config set environment_timeout 0 --section main'
      expect(dummy_class).to receive(:on).with(master, puppet).and_return(result)
      expect(dummy_class).to receive(:puppet).with(cmd).and_return(puppet)
      expect(dummy_class.disable_env_cache(master)).to eq(result)
    end

    it 'with too many arguments' do
      expect{ dummy_class.disable_env_cache(master, 'No Bueno') }.to raise_error(ArgumentError)
    end

    it 'with no arguments' do
      expect{ dummy_class.disable_env_cache }.to raise_error(ArgumentError)
    end

  end

end
