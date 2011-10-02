#!/usr/bin/env ruby

require 'tidyup'

puts Tidyup.tidyup(File.read(ARGV.first))
