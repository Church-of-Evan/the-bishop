# frozen_string_literal: true

require 'open3'

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

module EvanBot
  module Modules
    module AdminCommands
      extend Discordrb::Commands::CommandContainer

      command(:update,
              required_roles: [CONFIG['roles']['admin']],
              description: 'Update bot to latest commit') do |event|
        event.message.react '⌛'

        _out, err, status = Open3.capture3 'git fetch --prune && git pull'

        if status != 0
          return event.send_embed do |embed|
            embed.color = CONFIG['colors']['error']
            embed.title = 'Error updating'
            embed.description = "```\n#{err}\n```"
          end
        end

        event.send_embed do |embed|
          embed.color = CONFIG['colors']['success']
          embed.title = 'Repo updated successfully, restarting...'
          embed.description = "Running commit `#{`git rev-parse HEAD`[0..8]}`:\n```#{`git show -s --format=%s`}```"
        end
        event.message.delete_own_reaction '⌛'

        # will restart due to systemd
        exit
      end

      command(:reload,
              required_roles: [CONFIG['roles']['admin']],
              description: 'Reload all command containers') do |event|
        reload_modules(event.bot)
        event.message.react '✅'
      end

      command(:newclass,
              required_roles: [CONFIG['roles']['admin']],
              description: 'Create a new class role and channel. [admin only]') do |event, name|
        return event.message.react '❓' unless name && name =~ /\w+\d+/

        return 'That role already exists!' if ROLES.key? name

        server = event.server

        # update role list with new role
        new_role = server.create_role(
          name: name,
          mentionable: true
        )
        ROLES[name] = new_role.id

        # sort role list
        sorted_roles = ROLES.sort_by { |a| a[0][/\d+/].to_i }.to_h
        File.write('roles.yml', sorted_roles.to_yaml)

        can_view = Discordrb::Permissions.new
        can_view.can_read_messages = true # AKA view_channel

        new_channel = server.create_channel(
          "#{name.insert(name =~ /\d/, '-')}-questions",
          parent: CONFIG['class_categories'][name[/\d+/].to_i / 100 * 100],
          permission_overwrites: [
            Discordrb::Overwrite.new(new_role, allow: can_view),
            Discordrb::Overwrite.new(ROLES['all'], allow: can_view),
            Discordrb::Overwrite.new(server.everyone_role, deny: can_view)
          ]
        )

        event.channel.send_embed do |embed|
          embed.description = "Channel #{new_channel.mention} and role #{new_role.mention} created."
          embed.color = CONFIG['colors']['success']
        end

        # restart to pick up sorted roles from file
        # we can't sort ROLES in place because its a constant
        # TODO: handle this better /shrug
        exit
      end

      command(:role_message, required_roles: [CONFIG['roles']['admin']]) do |event|
        event.message.delete

        event.send_embed do |embed, components|
          embed.fields = [
            { name: 'Role Selection', value: "Select roles in the dropdowns below:\n(sorted by class number)" }
          ]
          embed.color = CONFIG['colors']['info']

          # since max of 25 choices per dropdown, break up by level
          components.row do |row|
            # general roles (not class)
            r = ROLES.filter { |n, _| n.match?(/^\D+$/) }
            row.select_menu(custom_id: 'role_add_general', placeholder: 'General roles', max_values: r.size) do |s|
              r.each do |role, id|
                s.option(label: role.capitalize, value: id.to_s)
              end
            end
          end
          components.row do |row|
            # 100/200 level
            r = ROLES.filter { |n, _| n.match?(/[12]\d\d/) }
            row.select_menu(custom_id: 'role_add_100/200', placeholder: '100/200-level classes',
                            max_values: r.size) do |s|
              r.each do |role, id|
                s.option(label: role.upcase, value: id.to_s)
              end
            end
          end
          components.row do |row|
            # 300 level
            r = ROLES.filter { |n, _| n.match?(/3\d\d/) }
            row.select_menu(custom_id: 'role_add_300', placeholder: '300-level classes', max_values: r.size) do |s|
              r.each do |role, id|
                s.option(label: role.upcase, value: id.to_s)
              end
            end
          end
          components.row do |row|
            # 400 level
            r = ROLES.filter { |n, _| n.match?(/4\d\d/) }
            row.select_menu(custom_id: 'role_add_400', placeholder: '400-level classes', max_values: r.size) do |s|
              r.each do |role, id|
                s.option(label: role.upcase, value: id.to_s)
              end
            end
          end
        end
      end
    end
  end
end
