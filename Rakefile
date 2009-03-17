begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rspactor"
    gem.summary = "RSpactor is a command line tool to automatically run your changed specs (much like autotest)."
    gem.email = "mislav.marohnic@gmail.com"
    gem.homepage = "http://github.com/mislav/rspactor"
    gem.authors = ["Mislav Marohnić", "Andreas Wolff", "Pelle Braendgaard"]
    gem.has_rdoc = false
  end
rescue LoadError
  puts "Jeweler gem (technicalpickles-jeweler) not found"
end

task :spec do
  system 'ruby -Ilib bin/rspactor'
end

task :default => :spec
