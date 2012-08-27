Given /^an orbspec named "([^"]*)"$/ do |name|
  write_file "foo.d", 'module foo;'
  write_file "test.d", 'module test;'
  write_file "dsss.conf", <<-eos
    [test.d]
    target = bin/#{name}
  eos
  write_file "#{name}.orbspec", <<-eos
    name "#{name}"
    summary "#{name} orb"
    version "0.0.1"
    files %w[test.d foo.d dsss.conf]
    executables %w[#{name}]
    bindir "bin"
    build "dsss"
  eos
end

Given /^an orbspec named "([^"]*)" with a dependency on "([^"]*)"$/ do |name, dependency|
  write_file "foo.d", 'module foo;'
  write_file "test.d", 'module test;'
  write_file "dsss.conf", <<-eos
    [test.d]
    target = bin/#{name}
  eos
  write_file "#{name}.orbspec", <<-eos
    name "#{name}"
    summary "#{name} orb"
    version "0.0.1"
    files %w[test.d foo.d dsss.conf]
    executables %w[#{name}]
    bindir "bin"
    build "dsss"
    orb "#{dependency}"
  eos
end

Given /^a repository named "([^"]*)"$/ do |name|
    step %{a directory named "#{name}"}
end

Given /^an orb named "([^"]*)"$/ do |name|
  step %{an orbspec named "#{name}"}
  step %{I successfully run `orb build #{name}`}
  step %{a file named "#{name}.orb" should exist}
end

Given /^an orb named "([^"]*)" with a dependency on "([^"]*)"$/ do |name, dependency|
  step %{an orbspec named "#{name}" with a dependency on "#{dependency}"}
  step %{I successfully run `orb build #{name}`}
  step %{a file named "#{name}.orb" should exist}
end

Given /^an orb named "([^"]*)" in the repository "([^"]*)"$/ do |name, source|
  step %{an orb named "#{name}"}
  step %{I successfully run `orb push #{name} -s #{source}`}
  step %{a file named "#{source}/index.xml" should exist}
  step %{a file named "#{source}/orbs/#{name}-0.0.1.orb" should exist}
  remove_file(name + ".orb")
end

Given /^the environment variable "([^"]*)" is "([^"]*)"$/ do |variable, value|
  set_env(variable, value)
end

Given /^an orb named "([^"]*)" with a dependency on "([^"]*)" in the repository "([^"]*)"$/ do |name, dependency, source|
  step %{an orb named "#{name}" with a dependency on "#{dependency}"}
  step %{I successfully run `orb push #{name} -s #{source}`}
  step %{a file named "#{source}/index.xml" should exist}
  step %{a file named "#{source}/orbs/#{name}-0.0.1.orb" should exist}
  remove_file(name + ".orb")
end