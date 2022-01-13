#!/usr/bin/env ruby
# frozen_string_literal: true

require 'discordrb'
require 'yaml'

CONFIG = YAML.load_file('config.yml')
ROLES = YAML.load_file('roles.yml')

bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'], prefix: CONFIG['prefix']

def reload_modules(bot)
  # remove all current handlers
  bot.clear!

  # force reload with load() instead of require()
  Dir.glob(File.join('modules', '*.rb')).each { |f| load f }

  # # re-register handlers into bot
  EvanBot::Modules.constants.each do |const|
    Discordrb::LOGGER.info "Loading #{const}"
    bot.include! EvanBot::Modules.const_get(const)
  end
end

# load modules
reload_modules(bot)

# register slash commands
# this only needs to happen once so dont do it on !reload
EvanBot::Modules::SlashCommands.register_commands(bot)

bot.ready do
  bot.listening = 'Evan'
  Discordrb::LOGGER.info 'Ready.'
end

# start bot
at_exit { bot.stop }
bot.run
