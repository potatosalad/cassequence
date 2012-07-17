require 'bundler/setup'

$:.push File.expand_path("../lib", __FILE__)
require 'pry'
require 'simplecov'
SimpleCov.start

require 'cassequence'


ENV['test'] = 'true'
