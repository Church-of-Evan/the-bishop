#!/usr/bin/env ruby
# frozen_string_literal: true

require 'discordrb'
require 'yaml'

CONFIG = YAML.load_file('config.yml')

# load inital files
module_files = Dir.glob(File.join('modules', '*.rb'))
module_files.each { |f| load f }

CONTAINERS = [EventHandlers, AdminCommands, GeneralCommands].freeze

bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'], prefix: CONFIG['prefix']

# load inital containers
CONTAINERS.each { |container| bot.include!(container) }

bot.ready do
  bot.listening = 'Evan'
  Discordrb::LOGGER.info 'Ready.'
end

# start bot
at_exit { bot.stop }
bot.run
