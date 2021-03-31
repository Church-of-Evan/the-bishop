# frozen_string_literal: true

require 'mathematical'
require 'mini_magick'
require 'tempfile'

# praise count mutex
PRAISE_MUTEX = Mutex.new unless defined? PRAISE_MUTEX

module GeneralCommands
  extend Discordrb::Commands::CommandContainer

  command(
    :latex,
    aliases: %i[eqn equation],
    description: 'Render a LaTeX math equation into an image'
  ) do |event, *equation|
    tempfile = Tempfile.new('equation')
    equation = equation.join(' ')

    begin
      eqn_filters = [
        ['`', ''], # remove any `s for code block
        ['\\text{', '\\backslash text~{'], # \text mode bogs down system
        ['\\\\', '\\'], # prevent double backslash, needed to make latex rendering work
        ['$', '\\$'], # $ is to enter/exit math mode but already in math mode so ignore
        ['"', '\\"'] # " could escape the latex function
      ]
      eqn_filters.each { |filter, replace| equation.gsub!(filter, replace) }
      equation.strip!

      raw_image = Mathematical.new(format: :png, ppi: 300.0).render("$#{equation}$")
      if raw_image[:exception]
        return event.send_embed do |embed|
          embed.color = CONFIG['colors']['error']
          embed.title = 'Error rendering equation'
          embed.description = "```\n#{raw_image[:exception]}\n```"
        end
      end

      # add background and padding for legibility
      clean_image = MiniMagick::Image.read(raw_image[:data], ext: 'png')
      clean_image.flatten                  # get rid of alpha channel
      clean_image.combine_options do |img| # add padding
        img.border 10
        img.bordercolor 'white'
      end
      clean_image.write tempfile.path

      event.send_file(tempfile, filename: 'equation.png')
    ensure
      # remove tempfile
      tempfile.close
      tempfile.unlink
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

  command(
    :role,
    aliases: [:roles],
    channels: [CONFIG['bot_channel'], CONFIG['testing_channel']],
    description: 'Add class roles to see channels for each class'
  ) do |event, action, *roles|

    # add disciples role here temporarily since event is broken
    event.author.add_role(CONFIG['roles']['disciple'])

    if %w(add remove).include? action
      last_completed = 'role'

      roles.each do |r|
        unless CONFIG['class_roles'][r]
          # if role not found
          event.message.react '❓'
          err_msg = "#{event.message.content.tr('`', '')}\n"
          err_msg += ' ' * err_msg.index(r, err_msg.index(last_completed) + 1) + '^' * r.length
          return event.channel.send_embed do |embed|
            embed.fields = [
              { name: 'Role not recognized:', value: "```#{err_msg}```" },
              { name: 'Example usage:', value: "`!role add cs325 cs381`\nCheck `!role` for valid roles" }
            ]
            embed.color = CONFIG['colors']['error']
          end
        end

        if action == 'add'
          event.author.add_role(CONFIG['class_roles'][r])
        else
          event.author.remove_role(CONFIG['class_roles'][r])
        end
        last_completed = r
      end
      event.message.react '✅'

    else # list roles if no action given
      event.channel.send_embed do |embed|
        embed.fields = [
          { name: 'Usage:', value: "`!role add role [role2 ...]`\n`!role remove role [role2 ...]`" },
          { name: 'Valid roles:', value: "`#{CONFIG['class_roles'].keys.map { |k| k.ljust 6 }.join('` `')}`" }
        ]
        embed.color = CONFIG['colors']['error']
      end
    end
  end

  command(:yeet, description: 'yote') do |event|
    event.send %w(
      evan\ says\ "yote"
      https://tenor.com/view/yeet-rafiki-simba-lion-king-gif-12559094
      https://tenor.com/view/big-yeet-spinning-gif-11694855
      https://tenor.com/view/dab-dancing-idgaf-gif-5661979
      https://giphy.com/gifs/memecandy-J1ABRhlfvQNwIOiAas
      https://tenor.com/view/bettywhite-dab-gif-5044603
    ).sample
  end
end
