require 'fsevent'

module RSpactor
  # based on http://github.com/sandro/beholder/commit/2ac026f8fc199b75944b8a2c1a3f80ee277dd81b
  class Listener < FSEvent
    attr_reader :last_event, :callback, :valid_extensions, :modified_directories
    
    def initialize(valid_extensions = nil)
      @valid_extensions = valid_extensions
      update_last_event
      super()
    end
    
    def on_change(directories)
      @modified_directories = directories
      callback.call(modified_files)
      update_last_event
    end
    
    def watch_directories(directories, &block)
      super(directories)
      @callback = block
    end
    
    
    def potentially_modified_files
      Dir.glob(modified_directories.map {|dir| File.join(dir, "**", "*")})
    end
    
    def modified_files
      potentially_modified_files.select do |file|
        next if File.directory?(file)
        next if ignore_file?(file)
        File.mtime(file) >= last_event || File.atime(file) >= last_event
      end
    end
    
    def ignore_file?(file)
      File.basename(file).index('.') == 0 or not valid_extension?(file)
    end
    
    def file_extension(file)
      file =~ /\.(\w+)$/ and $1
    end
    
    def valid_extension?(file)
      valid_extensions.nil? or valid_extensions.include?(file_extension(file))
    end
    
    def update_last_event
      @last_event = Time.now
    end
    
  end
end