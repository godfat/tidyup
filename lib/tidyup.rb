
module Tidyup
  module_function
  def tidyup str
    Tidyup.break_lines(Tidyup.scan_words(str))
  end

  def self.scan_words str
    if ''.respond_to?(:force_encoding)
      str.scan(/\w+|[^\b\s\w]/).sort
    else
      str.scan(/\w+|[^\b\s\w]/u).sort
    end
  end

  def self.break_lines words
    words.inject(['']){ |r, i|
      if word_size(r.last) + word_size(i) < terminal_width
        if double_width?(i)
          r.last << i
        else
          r.last << "#{i} "
        end
      else
        r.last << "\n"
        r << ''
      end
      r
    }.join
  end

  def self.word_size word
    return 0 if word.empty?
    word.chars.map{ |char|
      if double_width?(char)
        2
      else
        1
      end
    }.inject(&:+)
  end

  def self.double_width? char
    return false if char.nil? || char && char.empty?
    code = char.unpack('U').first
    code > 0xA0 && !(code > 0x452 && code < 0x1100)
  rescue ArgumentError => e
    if e.message.start_with?('malformed')
      false
    else
      raise
    end
  end

  def self.terminal_width
    @width ||= case    w = `stty size 2> /dev/null`.split[1].to_i
               when 0; w = case w = `tput cols 2> /dev/null`.to_i
                           when 0; 80
                           else  ; w
                           end
               else  ; w
               end
  end
end
