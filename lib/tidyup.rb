
module Tidyup
  module_function
  def tidyup str
    Tidyup.break_lines(Tidyup.scan_words(str))
  end

  ANSI = '(\e\[\d+(;\d+){0,2}m)'

  def self.scan_words str
    regexp = if ''.respond_to?(:force_encoding)
               /#{ANSI}?(\w+)|#{ANSI}?([^\e\b\s\w])?/
             else
               /#{ANSI}?(\w+)|#{ANSI}?([^\e\b\s\w])?/u
             end

    str.scan(regexp).inject([['', nil]]){ |r, i|
      word, color = [i[2] || i[5], i[0] || i[3]]
      r << [word, color || r.last.last] if word
      r
    }[1..-1].sort_by(&:join)
  end

  def self.break_lines words
    words.inject(['']){ |r, (word, color)|
      if word_size(r.last) + word_size(word) < terminal_width
        if double_width?(word)
          r.last << "#{color}#{word}"
        else
          r.last << "#{color}#{word} "
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
    word.gsub(/#{ANSI}/, '').chars.map{ |char|
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
