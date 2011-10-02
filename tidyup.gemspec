# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "tidyup"
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lin Jen-Shin (godfat)"]
  s.date = "2011-10-02"
  s.description = "! ( ) Tidy document s up your\n\nInspired by [The Art of Clean Up: Sorting and Stacking Everyday Objects][img]\n\n[img]: http://www.jeanniejeannie.com/2011/08/29/the-art-of-clean-up-sorting-and-stacking-everyday-objects/"
  s.email = ["godfat (XD) godfat.org"]
  s.executables = ["tidyup"]
  s.files = [
  ".gitignore",
  ".gitmodules",
  "CHANGES.md",
  "LICENSE",
  "README.md",
  "Rakefile",
  "bin/tidyup",
  "lib/tidyup.rb",
  "lib/tidyup/runner.rb",
  "lib/tidyup/version.rb",
  "task/.gitignore",
  "task/gemgem.rb",
  "tidyup.gemspec"]
  s.homepage = "https://github.com/godfat/tidyup"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "! ( ) Tidy document s up your"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
