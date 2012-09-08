require "java"
Dir[Pathname(__FILE__).dirname.parent + "jars/*.jar"].each { |jar| require jar }

require_relative "harbor/core"

config.helpers = Harbor::ViewHelpers.new
config.locales.default = Harbor::Locale::default

require "harbor/mail/mailer"
require "harbor/mail/servers/sendmail"

config.mailer = Harbor::Mail::Mailer
config.mail_server = Harbor::Mail::Servers::Sendmail

config.console = Harbor::Consoles::IRB

config.autoloader = Harbor::Autoloader.new
config.reloader   = Harbor::Reloader.new
