require 'spec/runner/formatter/base_formatter'

class RSpecGrowler < Spec::Runner::Formatter::BaseFormatter
  def dump_summary(duration, total, failures, pending)
    icon = if failures > 0
      'failed'
    elsif pending > 0
      'pending'
    else
      'success'
    end
    
    image_path = File.dirname(__FILE__) + "/../images/#{icon}.png"
    message = "#{total} examples, #{failures} failures"
    
    if pending > 0
      message << " (#{pending} pending)"
    end
    
    growl "Test Results", message, image_path, 0
  end
  
  def growl(title, msg, img, pri = 0)
    system("growlnotify -w -n rspactor --image #{img} -p #{pri} -m #{msg.inspect} #{title} &") 
  end
end

