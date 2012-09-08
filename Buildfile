require "rubygems"
require "pathname"

Project.local_task :jetty

# org.eclipse.jetty:jetty-server:jar:8.1.5.v20120716
repositories.remote << "http://mirrors.ibiblio.org/pub/mirrors/maven2"
repositories.remote << "http://repo1.maven.org/maven2/"

define "harbor" do
  project.version = "0.9.0"
  
  SERVLET_API = "javax.servlet:javax.servlet-api:jar:3.0.1"
  JETTY_UTIL  = "org.eclipse.jetty:jetty-util:jar:8.1.5.v20120716"
  
  compile.with transitive(SERVLET_API)
  compile.with transitive(JETTY_UTIL)
  
  # compile.with transitive("org.jruby:jruby:jar:1.7.0.preview2")
  
  task "jars" do
    artifact(SERVLET_API).invoke
    artifact(JETTY_UTIL).invoke
  end
  
  require "lib/harbor/version"
  package(:gem).spec do |spec|
    spec.name = "harbor"
    spec.summary = "Harbor Web Framework"
    spec.description = "JRuby Web Framework"
    spec.author = "Sam Smoot"
    spec.homepage = "https://github.com/sam/harbor"
    spec.email = "ssmoot@gmail.com"
    spec.version = Harbor::VERSION
    spec.platform = Gem::Platform::RUBY
    spec.files         = `git ls-files`.split("\n")
    spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
    spec.executables   = "harbor"
    spec.require_paths = ["lib"]
  
    spec.rdoc_options = [
      "-T", "harbor",
      "--line-numbers",
      "--main", "README.textile",
      "--title", "Harbor Documentation",
      "--exclude", "lib/harbor/commands/*",
      "lib/harbor.rb", "lib/harbor", "README.textile"
    ]
    
    spec.add_dependency "buildr"
    # spec.add_dependency "jruby-openssl"
    
    spec.add_development_dependency "ffi-ncurses"
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
  
  desc "Re-generate harbor.gemspec based on the Buildfile specification"
  task "gemspec" do
    File::open("harbor.gemspec", "w+") do |f|
      f.puts("#" * 80)
      f.puts("# %-76s #" % [ "WARNING: DO NOT MODIFY!!!" ])
      f.puts("# %-76s #" % [ "This file is generated by \"buildr harbor:gemspec\"" ])
      f.puts("#" * 80)
      f.puts
      f.puts package(:gem).spec.to_ruby
    end
  end
  
  require "rake/testtask"
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList["test/**/*_test.rb"]
    t.verbose = true
  end
  
  require "rdoc/task"  
  desc "Generate RDoc documentation"
  RDoc::Task.new do |rdoc|
    spec = package(:gem).spec
    
    rdoc.rdoc_dir = "doc"
    rdoc.title = spec.name
    rdoc.options = spec.rdoc_options.clone
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.rdoc_files.include spec.extra_rdoc_files
  
    # The lines below come from:
    #   https://github.com/apache/buildr/blob/trunk/rakelib/doc.rake#L35
    # include rake source for better inheritance rdoc
    # rdoc.rdoc_files.include('rake/lib/**.rb')
  end
  
  require "simplecov"
  desc "Run tests with code coverage enabled"
  task "coverage" do
    ENV["COVERAGE"] = "true"
    Rake::Task["test"].execute
  end
  
  require "buildr/jetty"
  task "jetty" => [ package(:war), jetty.use ] do |task|
    jetty.deploy("http://localhost:8080", task.prerequisites.first)
    puts 'Press CTRL-C to stop Jetty'
    trap 'SIGINT' do
      jetty.stop
    end
    Thread.stop
  end
end