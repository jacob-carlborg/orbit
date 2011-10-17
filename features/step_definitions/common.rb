Given /^I have an orbspec "([^"]*)"$/ do |name|
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