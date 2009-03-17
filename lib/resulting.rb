require 'spec/runner/formatter/base_formatter'

class RSpactorFormatter < Spec::Runner::Formatter::BaseFormatter
  def dump_summary(duration, total, failures, pending)
    image_path = File.dirname(__FILE__) + "/../images/rails_#{failures.zero?? 'ok' : 'fail'}.png"
    growl "Test Results", "#{total} examples, #{failures} failures", image_path, 0
  end
  
  def growl(title, msg, img, pri = 0)
    system("growlnotify -w -n rspactor --image #{img} -p #{pri} -m #{msg.inspect} #{title} &") 
  end
end

