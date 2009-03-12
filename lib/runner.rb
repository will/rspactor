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
        if spec_file = @inspector.determine_spec_file(file)
          puts spec_file
          files_to_spec << spec_file 
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
    #puts cmd
    system(cmd)
  end
  
  def self.spec_opts
    if File.exist?("spec/spec.opts")
      return "-O spec/spec.opts"
    else
      return "-c -f progress"
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
    %(RUBYOPT='-Ilib:spec #{ENV['RUBYOPT']}')
  end
end