# frozen_string_literal: true

require 'open3'

require_relative '../shared/role_components'
require_relative '../shared/classes_api'

module Bishop
  module Modules
    module AdminCommands
      extend Discordrb::Commands::CommandContainer

      command(:update,
              allowed_roles: CONFIG['roles']['admin'],
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
              allowed_roles: CONFIG['roles']['admin'],
              description: 'Reload all command containers') do |event|
        reload_modules(event.bot)
        event.message.react '✅'
      end

      command(:newclass,
              allowed_roles: CONFIG['roles']['admin'],
              description: 'Create a new class role and channel. [admin only]') do |event, name|
        return event.message.react '❓' unless name && name =~ /\w+\d+/

        return 'That role already exists!' if ROLES['classes'].key? name

        # try to fetch class name from classes.o.e api
        title = ClassesAPI.get_class_title(name)
        title ||= name.upcase # default to class slug if name not found

        server = event.server

        # update role list with new role
        new_role = server.create_role(name: name, mentionable: true)
        ROLES['classes'][name] = { 'id' => new_role.id, 'title' => title }

        # sort updated role list and write to file
        ROLES['classes'] = ROLES['classes'].sort_by { |slug, _data| slug[/\d+/].to_i }.to_h
        File.write(OPTIONS['--roles-file'], ROLES.to_yaml)

        # create new channel with visibility to roles
        can_view = Discordrb::Permissions.new [:read_messages]

        new_channel = server.create_channel(
          "#{name.insert(name =~ /\d/, '-')}-#{title.gsub(/\s+/, '-')}",
          parent: CONFIG['class_categories'][name[/\d+/].to_i / 100 * 100],
          permission_overwrites: [
            Discordrb::Overwrite.new(new_role, allow: can_view),
            Discordrb::Overwrite.new(ROLES['general']['allclasses']['id'], allow: can_view),
            Discordrb::Overwrite.new(server.everyone_role, deny: can_view)
          ]
        )

        SharedRoleComponents.update_select_message(event.bot)

        event.channel.send_embed do |embed|
          embed.description = "Channel #{new_channel.mention} and role #{new_role.mention} created."
          embed.color = CONFIG['colors']['success']
        end
      end

      command(:role_message, allowed_roles: CONFIG['roles']['admin']) do |event|
        # event.message.delete

        # event.send_embed do |embed, view|
        #   SharedRoleComponents.add_selects(embed, view)
        # end

        SharedRoleComponents.update_select_message(event.bot)
        event.message.react '✅'
      end
    end
  end
end
