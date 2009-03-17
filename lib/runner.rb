require 'inspector'
require 'interactor'
require 'listener'

class Runner
  
  def self.load
    dir = Dir.pwd
    @inspector  = Inspector.new(dir)
    @interactor = Interactor.new
    
    puts "** RSpactor is now watching at '#{dir}'"
    
    aborted = initial_spec_run_abort   
    @interactor.start_termination_handler
    run_all_specs unless aborted
    
    Listener.new(Inspector::EXTENSIONS) do |files|
      files_to_spec = []
      files.each do |file|
        spec_files = @inspector.determine_spec_files(file)
        unless spec_files.empty?
          puts spec_files.join("\n")
          files_to_spec.concat spec_files
        end
      end  
      run_spec_command(files_to_spec)
    end.run(dir)
  end
  
  def self.initial_spec_run_abort
    @interactor.wait_for_enter_key("** Hit <enter> to skip initial spec run", 3)
  end

  def self.run_all_specs
    run_spec_command('spec')
  end

  def self.run_spec_command(paths)
    paths = Array(paths)
    return if paths.empty?
    cmd = "#{ruby_opts} #{spec_runner} #{paths.join(" ")} #{spec_opts} "
    cmd << "-r #{File.dirname(__FILE__)}/resulting.rb -f RSpactorFormatter:STDOUT"
    run_command cmd
  end
  
  def self.run_command(cmd)
    system(cmd)
  end
  
  def self.spec_opts
    if File.exist?("spec/spec.opts")
      return "-O spec/spec.opts"
    else
      return "--color"
    end
  end
  
  def self.spec_runner
    if File.exist?("script/spec")
      "script/spec"
    else
      "spec"
    end
  end
  
  def self.ruby_opts
    other = ENV['RUBYOPT'] ? " #{ENV['RUBYOPT']}" : ''
    %(RUBYOPT='-Ilib:spec#{other}')
  end
end