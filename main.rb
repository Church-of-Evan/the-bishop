#!/usr/bin/env ruby
# frozen_string_literal: true

require 'discordrb'
require 'docopt'
require 'yaml'

doc = <<~DOCOPT
  The Bishop moderation bot.

  Usage:
    #{__FILE__} [--config-file=FILE] [--roles-file=FILE]

  Options:
    -h --help                   Show this screen.
    -c --config-file FILE       Path to config file [default: config.yml]
    -r --roles-file FILE        Path to roles file [default: roles.yml]
DOCOPT

OPTIONS = Docopt.docopt(doc)
Discordrb::LOGGER.debug "Options: #{OPTIONS}"

CONFIG = YAML.load_file(OPTIONS['--config-file'])
ROLES = YAML.load_file(OPTIONS['--roles-file'])

# initial load of command modules
Dir.glob(File.join('modules', '*.rb')).each { |f| load f }

bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'], prefix: CONFIG['prefix']

def reload_modules(bot)
  # remove all current handlers
  bot.clear!
  bot.commands.each_key { |c| bot.remove_command(c) }

  # "unload" modules by un-defining container name
  Bishop::Modules.constants.each { |m| Bishop::Modules.send(:remove_const, m) }

  # force reload with load instead of require
  Dir.glob(File.join('modules', '*.rb')).each { |f| load f }

  # re-register handlers into bot
  Bishop::Modules.constants.each do |m|
    Discordrb::LOGGER.info "Loading #{m}"
    bot.include! Bishop::Modules.const_get(m)
  end
end

# load modules
reload_modules(bot)

# register slash commands
# this only needs to happen once so dont do it on !reload
Bishop::Modules::SlashCommands.register_commands(bot)

bot.ready do
  bot.listening = 'Evan'
  Discordrb::LOGGER.info "Logged in as #{bot.profile.username}"
end

# start bot
at_exit { bot.stop }
bot.run
