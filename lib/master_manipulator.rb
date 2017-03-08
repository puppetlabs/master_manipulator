require 'master_manipulator/version'
require 'beaker'

module Beaker
  class TestCase
    %w( config service site log ).each do |lib|
      require "master_manipulator/#{lib}"
    end
    include MasterManipulator::Config
    include MasterManipulator::Service
    include MasterManipulator::Site
    include MasterManipulator::Log
  end
end
