require 'rspactor'

module RSpactor
  class Runner
    def self.load
      load_dotfile

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
    
    def self.load_dotfile
      dotfile = File.join(ENV['HOME'], '.rspactor')
      if File.exists?(dotfile)
        begin
          Kernel.load dotfile
        rescue => e
          $stderr.puts "Error while loading #{dotfile}: #{e}"
        end
      end
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
      run_command [ruby_opts, spec_runner, paths, spec_opts].flatten.join(' ')
    end

    def self.run_command(cmd)
      system(cmd)
    end

    def self.spec_opts
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

    def self.formatter_opts
      "-r #{File.dirname(__FILE__)}/../rspec_growler.rb -f RSpecGrowler:STDOUT"
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
end

# backward compatibility
Runner = RSpactor::Runner