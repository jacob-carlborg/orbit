Given /^an orbspec named "([^"]*)"$/ do |name|
  write_file "foo.d", 'module foo;'
  write_file "bar.d", 'module bar;'
  write_file "#{name}.orbspec", <<-eos
    name "#{name}"
    summary "#{name} orb"
    version "0.0.1"
    files %w[foo.d bar.d]
    executables %w[#{name}]
    bindir "bin"
  eos
end

Given /^a repository named "([^"]*)"$/ do |name|
    Given %{a directory named "#{name}"}
end

Given /^an orb named "([^"]*)"$/ do |name|
  Given %{an orbspec named "#{name}"}
  When %{I successfully run `orb build #{name}`}
  Then %{a file named "#{name}.orb" should exist}
end

Given /^an orb named "([^"]*)" in the repository "([^"]*)"$/ do |name, source|
  Given %{an orb named "#{name}"}
  When %{I successfully run `orb push #{name} -s #{source}`}
  Then %{a file named "#{source}/index.xml" should exist}
  And %{a file named "#{source}/orbs/#{name}-0.0.1.orb" should exist}
end