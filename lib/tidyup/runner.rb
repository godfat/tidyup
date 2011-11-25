
module Tidyup; end
module Tidyup::Runner
  module_function
  def options
    @options ||=
    [['-0, --mode 0' , 'Sort by colors'               ],
     ['-1, --mode 1' , 'Sort by colors (broken words)'],
     ['-2, --mode 2' , 'Sort by words'                ],
     ['-3, --mode 3' , 'Sort by words  (broken words)'],
     ['-h, --help'   , 'Print this message'           ],
     ['-v, --version', 'Print the version'            ]]
  end

  def run argv=ARGV
    @mode = 0
    paths = parse(argv)
    require 'tidyup'
    input = if paths.empty?
              $stdin.read
            else
              paths.map{ |path| File.read(path) }.join(' ')
            end
    puts Tidyup.tidyup(input, @mode)
  end

  def parse argv
    paths = []
    until argv.empty?
      case arg = argv.shift
      when /^-0/, /^--mode=?\s*0/
        @mode = 0

      when /^-1/, /^--mode=?\s*1/
        @mode = 1

      when /^-2/, /^--mode=?\s*2/
        @mode = 2

      when /^-3/, /^--mode=?\s*3/
        @mode = 3

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
