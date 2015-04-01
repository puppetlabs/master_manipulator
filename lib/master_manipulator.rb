require 'master_manipulator/version'
require 'beaker'

module MasterManipulator
  %w( config service site ).each do |lib|
    require "master_manipulator/#{lib}"
  end
end
