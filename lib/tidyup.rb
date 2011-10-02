
module Tidyup
  module_function
  def tidyup str
    Tidyup.break_lines(Tidyup.scan_words(str))
  end

  def self.scan_words str
    str.scan(/\w+|[^\s\w]/).sort
  end

  def self.break_lines words
    words.inject(['']){ |r, i|
      if r.last.size + i.size < Tidyup.terminal_width
        r.last << "#{i} "
      else
        r.last << "\n"
        r << ''
      end
      r
    }.join
  end

  def self.terminal_width
    @width ||= case    w = `stty size 2> /dev/null`.split[1].to_i
               when 0; w = case `tput cols 2> /dev/null`.to_i
                           when 0; 80
                           else  ; w
                           end
               else  ; w
               end
  end
end
