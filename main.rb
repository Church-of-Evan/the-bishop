# frozen_string_literal: true

require 'discordrb'
require 'yaml'

CONFIG = YAML.load_file('config.yml')

bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'], prefix: CONFIG['prefix']

bot.command :role do |event, action, *roles|
  if %w[add remove].include? action
    roles.each do |r|
      return event.message.react '❓' unless CONFIG['class_roles'][r]

      if action == 'add'
        event.author.add_role(CONFIG['class_roles'][r])
      else
        event.author.remove_role(CONFIG['class_roles'][r])
      end
    end
    event.message.react '✅'
  else # list roles if no action given
    event.channel.send_embed do |embed|
      embed.fields = [
        { name: 'Usage:', value: '`!role add role role2 ...`
        `!role remove role role2 ...`' },
        { name: 'Valid roles:', value: "`#{CONFIG['class_roles'].keys.join('` `')}`" }
      ]
      embed.color = CONFIG['colors']['error']
    end
  end
end

bot.command :praise do |event|
  praises = File.open('praises').read.to_i
  praises += 1
  event.channel.send_embed do |embed|
    embed.title = '🙏 Praise be to Evan! 🙏'
    embed.description = "*Praises x#{praises}*"
    embed.color = CONFIG['colors']['success']
  end
  File.open('praises', 'w') { |f| f.write praises }
  nil
end

# add :pray: react to the God King (praise be btw)
bot.message do |event|
  event.message.react '🙏' if event.author.roles.any? { |r| r.id == CONFIG['roles']['god'] }
end

# Start bot
bot.ready { puts 'Bot is ready.' }
at_exit { bot.stop }
bot.run
