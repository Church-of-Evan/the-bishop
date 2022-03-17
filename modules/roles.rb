# frozen_string_literal: true

module Bishop
  module Modules
    module RoleCommands
      extend Discordrb::Commands::CommandContainer

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
              err_msg += (' ' * err_msg.index(r, err_msg.index(last_completed) + 1)) + ('^' * r.length)
              embed = Discordrb::Webhooks::Embed.new(color: CONFIG['colors']['error'])
              embed.fields = [
                { name: 'Role not recognized:',
                  value: "```#{err_msg}```" },
                { name: 'Missing a class?',
                  value: 'If we are missing a class, let us know and we will add a channel!' },
                { name: 'Try using slash commands!',
                  value: "`/role add`\n`/role remove`" }
              ]
              return event.message.reply! '', embed: embed, mention_user: true
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
          general_roles = ROLES.filter { |n, _| n.match?(/^\D+$/) }
          class_roles = ROLES.filter { |n, _| n.match?(/\d/) }

          event.channel.send_embed do |embed|
            embed.fields = [
              { name: 'Missing a class?',
                value: 'If we are missing a class, let us know and we will add a channel!' },
              { name: 'General roles:',
                value: "`#{general_roles.keys.join('` `')}`" },
              { name: 'Class roles:',
                value: "`#{class_roles.keys.map { |k| k.ljust 7 }.join('` `')}`" },
              { name: 'Slash commands:',
                value: <<~USAGE,
                  `/role list`
                  `/role add`
                  `/role remove`
                USAGE
                inline: true },
              { name: 'Classic commands:',
                value: <<~USAGE,
                  `!role list`
                  `!role add foo [bar baz ...]`
                  `!role remove foo [bar baz ...]`
                USAGE
                inline: true }
            ]
            embed.color = CONFIG['colors']['error']
          end
        end
      end
    end
  end
end
