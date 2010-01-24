require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspactor"
    gem.summary = "RSpactor is a command line tool to automatically run your changed specs & cucumber features."
    gem.description = "RSpactor is a command line tool to automatically run your changed specs & cucumber features (much like autotest)."
    gem.email = "thibaud@thibaud.me"
    gem.homepage = "http://github.com/guillaumegentil/rspactor"
    gem.authors = ["Mislav Marohnić", "Andreas Wolff", "Pelle Braendgaard", "Thibaud Guillaume-Gentil"]
    gem.add_dependency "ruby-fsevent", ">= 0.2.1"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

desc "starts RSpactor"
task :rspactor do
  system "ruby -Ilib bin/rspactor"
end

task :spec => :check_dependencies

task :default => :rspactor

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rspactor #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end