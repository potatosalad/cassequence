require 'bundler/setup'

$:.push File.expand_path("../lib", __FILE__)
require 'cassequence'
require 'pry'

require 'simplecov'
SimpleCov.start

ENV['test'] = 'true'
