require 'bundler/setup'

$:.push File.expand_path("../lib", __FILE__)
require 'cassequence'
require 'pry'

ENV['test'] = 'true'
