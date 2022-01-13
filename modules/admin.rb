# frozen_string_literal: true

require 'open3'

require_relative '../shared/role_components'

module EvanBot
  module Modules
    module AdminCommands
      extend Discordrb::Commands::CommandContainer

      command(:update,
              required_roles: [CONFIG['roles']['admin']],
              description: 'Update bot to latest commit') do |event|
        event.message.react '⌛'

        # reset lockfile because bunder on ubuntu changes the version string >:(
        `git checkout -- Gemfile.lock`

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
        new_role = server.create_role(name: name, mentionable: true)
        ROLES[name] = new_role.id

        # sort role list
        sorted_roles = ROLES.sort_by { |a| a[0][/\d+/].to_i }.to_h
        File.write('roles.yml', sorted_roles.to_yaml)

        can_view = Discordrb::Permissions.new [:read_messages]

        new_channel = server.create_channel(
          "#{name.insert(name =~ /\d/, '-')}-questions",
          parent: CONFIG['class_categories'][name[/\d+/].to_i / 100 * 100],
          permission_overwrites: [
            Discordrb::Overwrite.new(new_role, allow: can_view),
            Discordrb::Overwrite.new(ROLES['allclasses'], allow: can_view),
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

        event.send_embed do |embed, view|
          RoleComponentBuilder.role_add_selects(embed, view)
        end
      end
    end
  end
end
