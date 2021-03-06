require "rubygems"

unless ENV["TRAVIS"]
  require "bundler/setup"
end

require "buildr/jetty"
require "pathname"
require "ci/reporter/rake/minitest"
require "rdoc/task"
require "rake/testtask"

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require "harbor/version"

# Tests
task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

desc "Run tests with code coverage enabled"
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task["test"].execute
end

Project.local_task :jetty

# org.eclipse.jetty:jetty-server:jar:8.1.5.v20120716
repositories.remote << "http://mirrors.ibiblio.org/pub/mirrors/maven2"
repositories.remote << "http://repo1.maven.org/maven2/"

define "harbor" do
  project.version = "0.9.0"
  
  compile.with transitive("org.mortbay.jetty:servlet-api:jar:3.0.20100224")

  # compile.with transitive("org.jruby:jruby:jar:1.7.0.preview2")
  
  package(:gem).spec do |spec|
    spec.name = "harbor"
    spec.summary = "Harbor Web Framework"
    spec.description = "JRuby Web Framework"
    spec.author = "Sam Smoot"
    spec.homepage = "https://github.com/sam/harbor"
    spec.email = "ssmoot@gmail.com"
    spec.version = Harbor::VERSION
    spec.platform = "java"
    spec.files         = `git ls-files`.split("\n")
    spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
    spec.executables   = "harbor"
    spec.require_paths = ["lib"]
  
    spec.rdoc_options = [
      "--line-numbers",
      "--main", "README.textile",
      "--title", "Harbor Documentation"
    ]
    
    spec.add_dependency "buildr"
    # spec.add_dependency "jruby-openssl"
    
    spec.add_development_dependency "simplecov"
    spec.add_development_dependency "rdoc", ">= 2.4.2"
    spec.add_development_dependency "builder"
    spec.add_development_dependency "minitest"
    spec.add_development_dependency "mocha"
    spec.add_development_dependency "listen"
  
    spec.add_runtime_dependency "erubis"
    spec.add_runtime_dependency "mime-types"
    spec.add_runtime_dependency "tilt"
  end
  
  task "jetty" => [ package(:war), jetty.use ] do |task|
    jetty.deploy("http://localhost:8080", task.prerequisites.first)
    puts 'Press CTRL-C to stop Jetty'
    trap 'SIGINT' do
      jetty.stop
    end
    Thread.stop
  end
  
  task "rdoc" do
    sh <<EOS.strip
rdoc -T harbor --line-numbers --main README.textile --title "Harbor Documentation" \
--exclude "lib/harbor/commands/*" lib/harbor.rb lib/harbor README.textile
EOS
  end
end