# frozen_string_literal: true

require 'discordrb'
require 'yaml'

CONFIG = YAML.load_file('config.yml')

bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'], prefix: CONFIG['prefix']

bot.command :role do |event, action, *roles|
  if %w(add remove).include? action
    roles.each do |r|
      return event.message.react '❓' if !CONFIG['classroles'][r]

      if action == 'add'
        event.author.add_role(CONFIG['classroles'][r])
      else
        event.author.remove_role(CONFIG['classroles'][r])
      end
    end
    event.message.react '✅'
  else # list roles if no action given
    event.channel.send_embed do |embed|
      embed.description = <<~EOM
        Usage: `!role (add|remove) role role2 ...`
        Valid roles:
        `#{CONFIG['classroles'].keys.join('` `')}`
      EOM
      embed.color = CONFIG['colors']['error']
    end
  end
end

# Start bot
bot.ready { puts 'Bot is ready.' }
at_exit { bot.stop }
bot.run
