#!/usr/bin/env rake
require "bundler/gem_tasks"

namespace :data do
  desc "Load test data structures."
  task :load do
    schema_path = "#{File.expand_path(Dir.pwd)}/spec/support/schema.txt"
    begin
      sh("cassandra-cli --host localhost --batch < #{schema_path}")
    rescue
      puts "Schema already loaded."
    end
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec' => 'data:load')

task :default => :spec
