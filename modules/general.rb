# frozen_string_literal: true

require 'tempfile'

require_relative '../shared/latex_renderer'

# praise count mutex
PRAISE_MUTEX = Mutex.new unless defined? PRAISE_MUTEX

module Bishop
  module Modules
    module GeneralCommands
      extend Discordrb::Commands::CommandContainer

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

      command(:latex,
              aliases: %i[eqn equation],
              description: 'Render a LaTeX math equation into an image') do |event, *equation|
        equation = equation.join(' ')

        Tempfile.create(%w(equation png)) do |tempfile|
          tempfile.binmode
          begin
            LatexRenderer.render_latex_equation(tempfile, "$#{equation}$")
            event.send_file(tempfile, filename: 'equation.png')
          rescue StandardError => e
            event.send_embed do |embed|
              embed.color = CONFIG['colors']['error']
              embed.title = 'Error rendering equation'
              embed.description = "```\n#{e}\n```"
            end
          end
        end

        nil # prevent implicit return message
      end

      command(:praise, channels: [CONFIG['chapel_channel'], CONFIG['testing_channel']]) do |event|
        PRAISE_MUTEX.synchronize do
          praises = File.read('praises').to_i
          praises += 1
          event.channel.send_embed do |embed|
            embed.title = '🙏 Praise be to Evan! 🙏'
            embed.description = "*Praises x#{praises}*"
            embed.color = CONFIG['colors']['success']
            embed.thumbnail = {
              url: 'https://media.discordapp.net/attachments/758182759683457035/758243415459627038/TempDorime.png'
            }
          end
          File.write('praises', praises)
          nil
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

      command(:lug, aliases: %i[plug]) do
        'https://discord.gg/3Jfq6aXy5B 🔌'
      end
    end
  end
end
