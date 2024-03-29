
module Tidyup; end
module Tidyup::Runner
  module_function
  def options
    @options ||=
    [['-c, --color'   , 'Color-aware (default)'],
     ['-n, --no-color', 'Ignore colors'        ],
     ['-h, --help'    , 'Print this message'   ],
     ['-v, --version' , 'Print the version'    ]]
  end

  def run argv=ARGV
    @color = true
    paths = parse(argv)
    require 'tidyup'
    input = if paths.empty?
              $stdin.read
            else
              paths.map{ |path| File.read(path) }.join(' ')
            end
    puts Tidyup.tidyup(input, @color)
  end

  def parse argv
    paths = []
    until argv.empty?
      case arg = argv.shift
      when /^-c/, /^--color/
        @color = true

      when /^-n/, /^--no-color/
        @color = false

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
