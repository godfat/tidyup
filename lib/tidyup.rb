
module Tidyup
  module_function
  def tidyup str, mode=0
    Tidyup.break_lines(Tidyup.scan_words(str, mode))
  end

  ANSI = '(\e\[\d+(;\d+){0,2}m)'

  def self.scan_words str, mode=0
    if ''.respond_to?(:force_encoding)
      last_color = ''
      str.scan(/[#{ANSI}\w]+|[^\e\b\s\w]/).inject([]){ |r, word|
        text       = text(word).strip
        color      = word[/#{ANSI}$/, 1] || last_color
        last_color = color

        next r if text.empty?

        if mode % 2 == 1 # broken words
          # TODO: bugs! some words are missing
          r.push(*word.scan(/(#{ANSI}\w)/).map{ |w| [w.first, color] })
        else
          r << [word, color]
        end

        r
      }.sort_by{ |(word, color)|
        text  = text(word)
        char  = text[0]
        color = word[0..word.index(char)][/#{ANSI}$/, 1] || color if char
        seq   = color.scan(/\d+/).map(&:to_i).last
        if mode <= 1
          [seq, text]
        else
          [text, seq]
        end
      }.map{ |(word, color)| "#{color}#{word}" }
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

  def self.word_size word
    word = text(word)
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
    char = text(char)
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

  def self.text word
    word.gsub(/#{ANSI}/, '')
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
