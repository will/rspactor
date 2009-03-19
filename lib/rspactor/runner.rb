require 'rspactor'

module RSpactor
  class Runner
    def self.start
      new(Dir.pwd).start
    end
    
    attr_reader :dir, :inspector, :interactor
    
    def initialize(dir)
      @dir = dir
    end
    
    def start
      load_dotfile
      puts "** RSpactor is now watching at '#{dir}'"
      start_interactor
      start_listener
    end
    
    def start_interactor
      @interactor = Interactor.new
      aborted = @interactor.wait_for_enter_key("** Hit <enter> to skip initial spec run", 3)
      @interactor.start_termination_handler
      run_all_specs unless aborted
    end
    
    def start_listener
      @inspector = Inspector.new(dir)

      Listener.new(Inspector::EXTENSIONS) do |files|
        spec_changed_files(files)
      end.run(dir)
    end
    
    def load_dotfile
      dotfile = File.join(ENV['HOME'], '.rspactor')
      if File.exists?(dotfile)
        begin
          Kernel.load dotfile
        rescue => e
          $stderr.puts "Error while loading #{dotfile}: #{e}"
        end
      end
    end

    def run_all_specs
      run_spec_command('spec')
    end

    def run_spec_command(paths)
      paths = Array(paths)
      if paths.empty?
        @last_run_failed = nil
      else
        cmd = [ruby_opts, spec_runner, paths, spec_opts].flatten.join(' ')
        @last_run_failed = run_command(cmd)
      end
    end
    
    def last_run_failed?
      @last_run_failed == false
    end
    
    protected

    def run_command(cmd)
      system(cmd)
      $?.success?
    end
    
    def spec_changed_files(files)
      files_to_spec = files.inject([]) do |all, file|
        all.concat inspector.determine_spec_files(file)
      end
      unless files_to_spec.empty?
        puts files_to_spec.join("\n")
        
        previous_run_failed = last_run_failed?
        run_spec_command(files_to_spec)
        
        if previous_run_failed and not last_run_failed?
          run_all_specs
        end
      end
    end
    
    private

    def spec_opts
      if File.exist?('spec/spec.opts')
        opts = File.read('spec/spec.opts').gsub("\n", ' ')
      else
        opts = "--color"
      end

      opts << ' ' << formatter_opts
      # only add the "progress" formatter unless no other (besides growl) is specified
      opts << ' -f progress' unless opts.scan(/\s(?:-f|--format)\b/).length > 1

      opts
    end

    def formatter_opts
      "-r #{File.dirname(__FILE__)}/../rspec_growler.rb -f RSpecGrowler:STDOUT"
    end

    def spec_runner
      if File.exist?("script/spec")
        "script/spec"
      else
        "spec"
      end
    end

    def ruby_opts
      other = ENV['RUBYOPT'] ? " #{ENV['RUBYOPT']}" : ''
      %(RUBYOPT='-Ilib:spec#{other}')
    end
  end
end

# backward compatibility
Runner = RSpactor::Runner