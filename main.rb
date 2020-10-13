# frozen_string_literal: true

require 'discordrb'
require 'yaml'

CONFIG = YAML.load_file('config.yml')

bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'], prefix: CONFIG['prefix']

bot.command(:ping) do |event|
  ping_ts = event.message.timestamp
  pong_msg = event.channel.send_embed do |embed|
    embed.color = CONFIG['colors']['success']
    embed.title = 'Pong!'
  end
  pong_ts = pong_msg.timestamp
  embed = Discordrb::Webhooks::Embed.new
  embed.color = CONFIG['colors']['success']
  embed.title = 'Pong!'
  embed.description = "⌚ #{((pong_ts.to_f - ping_ts.to_f)*1000).round(1)}ms"
  pong_msg.edit('', embed)
end

bot.command(:role, channels: [CONFIG['bot_channel']]) do |event, action, *roles|
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

# command to create new class role & channel
bot.command(:newclass, required_roles: [CONFIG['roles']['admin']]) do |event, name|
  return event.message.react '❓' unless name && name =~ /\w+\d+/

  server = event.server

  new_role = server.create_role(name: name)

  # update !role list with new role
  CONFIG['class_roles'][name] = new_role.id
  File.write('config.yml', CONFIG.to_yaml)

  can_view = Discordrb::Permissions.new
  can_view.can_read_messages = true # AKA view_channel

  new_channel = server.create_channel(
    "#{name.insert(name =~ /\d/, '-')}-questions",
    parent: CONFIG['class_category'],
    permission_overwrites: [
      Discordrb::Overwrite.new(new_role, allow: can_view),
      Discordrb::Overwrite.new(CONFIG['class_roles']['all'], allow: can_view),
      Discordrb::Overwrite.new(server.everyone_role, deny: can_view)
    ]
  )

  event.channel.send_embed do |embed|
    embed.description = "Channel #{new_channel.mention} and role #{new_role.mention} created."
    embed.color = CONFIG['colors']['success']
  end
end

bot.command :praise do |event|
  praises = File.open('praises').read.to_i
  praises += 1
  event.channel.send_embed do |embed|
    embed.title = '🙏 Praise be to Evan! 🙏'
    embed.description = "*Praises x#{praises}*"
    embed.color = CONFIG['colors']['success']
    embed.thumbnail = {
      url: 'https://media.discordapp.net/attachments/758182759683457035/758243415459627038/TempDorime.png'
    }
  end
  File.open('praises', 'w') { |f| f.write praises }
  nil
end

# add :pray: react to the God King (praise be btw)
bot.message do |event|
  event.message.react '🙏' if event.author.roles.any? { |r| r.id == CONFIG['roles']['god'] }
end

# add role on member join
bot.member_join do |event|
  event.user.add_role(CONFIG['roles']['disciple'])
end

# Start bot
bot.ready { puts 'Bot is ready.' }
at_exit { bot.stop }
bot.run
