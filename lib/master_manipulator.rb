require 'master_manipulator/version'
require 'beaker'

module Beaker
  class TestCase
    %w( config service site ).each do |lib|
      require "master_manipulator/#{lib}"
    end
    include MasterManipulator::Config
    include MasterManipulator::Service
    include MasterManipulator::Site
  end
end
