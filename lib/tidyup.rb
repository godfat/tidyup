
module Tidyup
  module_function
  def tidyup str, color=true
    if color
      Tidyup.break_lines_color(Tidyup.scan_words_color(str))
    else
      Tidyup.break_lines_color(      Tidyup.scan_words(      str))
    end
  end

  ANSI = '(\e\[\d+(;\d+){0,2}m)'

  def self.scan_words str
    if ''.respond_to?(:force_encoding)
      str.scan(/[#{ANSI}\w]+|[#{ANSI}[^\e\b\s\w]]/).inject([['', nil]]){ |r,i|
        word, color = [i, i[/#{ANSI}$/, 1] || (r.reverse.find{ |(_,c)| c }||[]).last]
        r << [word, color] if word && !word.gsub(/#{ANSI}/, '').strip.empty?
        r
      }.sort_by{ |v|
        color = v.first[/^#{ANSI}/] || v.last || ''
        v.first.gsub(/#{ANSI}/, '') + color }
    else
      str.scan(/\w+|[^\e\b\s\w]/u).sort
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

  def self.scan_words_color str
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

  def self.break_lines_color words
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
    }.inject(&:+) || 0
  end

  def self.double_width? char
    char = char.gsub(/#{ANSI}/, '')
    return false if char.empty?
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
