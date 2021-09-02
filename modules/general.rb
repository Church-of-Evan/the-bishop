# frozen_string_literal: true

require 'tempfile'

require_relative '../shared/latex_renderer'

# praise count mutex
PRAISE_MUTEX = Mutex.new unless defined? PRAISE_MUTEX

module GeneralCommands
  extend Discordrb::Commands::CommandContainer

  command(:latex,
          aliases: %i[eqn equation],
          description: 'Render a LaTeX math equation into an image') do |event, *equation|
    equation = equation.join(' ')

    Tempfile.create(%w(equation png)) do |tempfile|
      tempfile.binmode
      begin
        LatexRenderer.render_latex_equation(tempfile, equation)
        event.send_file(tempfile, filename: 'equation.png')
      rescue StandardError => e
        event.send_embed do |embed|
          embed.color = CONFIG['colors']['error']
          embed.title = 'Error rendering equation'
          embed.description = "```\n#{e}\n```"
        end
      end
    end
    nil
  end

  command(:ping, description: 'Pong!') do |event|
    ping_ts = event.message.timestamp
    pong_msg = event.channel.send_embed do |embed|
      embed.color = CONFIG['colors']['success']
      embed.title = 'Pong!'
    end
    pong_ts = pong_msg.timestamp

    embed = Discordrb::Webhooks::Embed.new
    embed.color = CONFIG['colors']['success']
    embed.title = 'Pong!'
    embed.description = "⌚ #{((pong_ts.to_f - ping_ts.to_f) * 1000).round(1)}ms"
    pong_msg.edit('', embed)
  end

  command(:praise, channels: [CONFIG['chapel_channel'], CONFIG['testing_channel']]) do |event|
    PRAISE_MUTEX.synchronize do
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
  end

  command(:role,
          aliases: [:roles],
          channels: [CONFIG['bot_channel'], CONFIG['testing_channel']],
          description: 'Add class roles to see channels for each class') do |event, action, *roles|
    # add disciples role here to allow access to server
    event.author.add_role(CONFIG['roles']['disciple'])

    if %w(add remove).include? action
      last_completed = 'role'

      # noop if no roles given
      return unless roles.any?

      roles.each do |r|
        r.downcase!
        unless ROLES[r]
          # if role not found
          event.message.react '❓'
          err_msg = "#{event.message.content.tr('`', '')}\n"
          err_msg += ' ' * err_msg.index(r, err_msg.index(last_completed) + 1) + '^' * r.length
          embed = Discordrb::Webhooks::Embed.new
          embed.fields = [
            { name: 'Role not recognized:', value: "```#{err_msg}```" },
            { name: 'Try using slash commands!', value: "`/role add`\n`/role remove`" }
          ]
          embed.color = CONFIG['colors']['error']
          return event.message.reply! '', embed: embed
        end

        if action == 'add'
          event.author.add_role(ROLES[r])
        else
          event.author.remove_role(ROLES[r])
        end
        last_completed = r
      end
      event.message.react '✅'

    else # list roles if no action given
      event.channel.send_embed do |embed|
        embed.fields = [
          { name: 'Valid roles:', value: "`#{ROLES.keys.map { |k| k.ljust 7 }.join('` `')}`" },
          { name: 'Missing a class?', value: 'If we are missing a class, let us know and we will add a channel!' },
          { name: 'Usage:', value: "`/role add`\n`/role remove`" },
          { name: 'Legacy commands:', value: "`!role add foo [bar baz ...]`\n`!role remove foo [bar baz ...]`" }
        ]
        embed.color = CONFIG['colors']['error']
      end
    end
  end

  command(:yeet, description: 'yote') do |event|
    event.send [
      'evan says "yote"',
      'https://tenor.com/view/yeet-rafiki-simba-lion-king-gif-12559094',
      'https://tenor.com/view/big-yeet-spinning-gif-11694855',
      'https://tenor.com/view/dab-dancing-idgaf-gif-5661979',
      'https://giphy.com/gifs/memecandy-J1ABRhlfvQNwIOiAas',
      'https://tenor.com/view/bettywhite-dab-gif-5044603'
    ].sample
  end
end
