
module Tidyup; end
module Tidyup::Runner
  module_function
  def options
    @options ||=
    [['-h, --help'       , 'Print this message'                      ],
     ['-v, --version'    , 'Print the version'                       ]]
  end

  def run argv=ARGV
    paths = parse(argv)
    require 'tidyup'
    input = if paths.empty?
              $stdin.read
            else
              paths.map{ |path| File.read(path) }.join(' ')
            end
    puts Tidyup.tidyup(input).inject(['']){ |r, i|
      if r.last.size + i.size < width
        r.last << "#{i} "
      else
        r.last << "\n"
        r << ''
      end
      r
    }.join
  end

  def width
    @width ||= case    w = `stty size 2> /dev/null`.split[1].to_i
               when 0; w = case `tput cols 2> /dev/null`.to_i
                           when 0; 80
                           else  ; w
                           end
               else  ; w
               end
  end

  def parse argv
    paths = []
    until argv.empty?
      case arg = argv.shift
      when /^-h/, '--help'
        puts(help)
        exit

      when /^-v/, '--version'
        require 'tidyup/version'
        puts(Tidyup::VERSION)
        exit

      else
        paths << arg
      end
    end
    paths
  end

  def help
    maxn = options.transpose.first.map(&:size).max
    maxd = options.transpose.last .map(&:size).max
    "Usage: tidyup [file ...]\n" +
    options.map{ |(name, desc)|
      if desc.empty?
        name
      else
        sprintf("  %-*s  %-*s", maxn, name, maxd, desc)
      end
    }.join("\n")
  end
end
