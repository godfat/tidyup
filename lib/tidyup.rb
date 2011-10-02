
module Tidyup
  module_function
  def tidyup str
    Tidyup.break_lines(Tidyup.scan_words(str))
  end

  def self.scan_words str
    # //u is only needed for ruby 1.8, no-op in 1.9
    str.scan(/\w+|[^\s\w]/u).sort
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
    return false unless char.respond_to?(:codepoints)
    return false if char.nil? || char && char.empty?
    code = char.codepoints.to_a.first
    code > 0xA0 && !(code > 0x452 && code < 0x1100)
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
