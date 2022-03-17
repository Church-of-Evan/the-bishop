# frozen_string_literal: true

require_relative '../shared/role_components'

module Bishop
  module Modules
    module SlashCommands
      extend Discordrb::EventContainer

      def self.register_commands(bot)
        Discordrb::LOGGER.info 'Registering /role'

        if bot.get_application_commands(server_id: ENV['SERVER_ID']).any? { |c| c.name == 'role' }
          Discordrb::LOGGER.info '  already registered, skipping'
          return
        end

        bot.register_application_command(:role, 'Manage your class roles', server_id: ENV['SERVER_ID']) do |cmd|
          cmd.subcommand(:add, 'Select class roles to add')
          cmd.subcommand(:remove, 'Select roles to remove from yourself')
          cmd.subcommand(:list, 'List all valid class roles')
        end
      end

      application_command(:role).subcommand(:list) do |event|
        event.respond ephemeral: true do |builder|
          general_roles = ROLES.filter { |n, _| n.match?(/^\D+$/) }
          class_roles = ROLES.filter { |n, _| n.match?(/\d/) }

          builder.add_embed do |embed|
            embed.fields = [
              { name: 'Missing a class?', value: 'If we are missing a class, let us know and we will add a channel!' },
              { name: 'General roles:', value: "`#{general_roles.keys.join('` `')}`" },
              { name: 'Class roles:', value: "`#{class_roles.keys.map { |k| k.ljust 7 }.join('` `')}`" },
              { name: 'Usage:', value: "`/role add`\n`/role remove`" },
              { name: 'Legacy commands:', value: "`!role add foo [bar baz ...]`\n`!role remove foo [bar baz ...]`" }
            ]
            embed.color = CONFIG['colors']['error']
          end
        end
      end

      application_command(:role).subcommand(:add) do |event|
        event.respond(ephemeral: true) do |builder, view|
          embed = Discordrb::Webhooks::Embed.new
          RoleComponentBuilder.role_add_selects(embed, view)
          builder << embed
        end
      end

      %w(general 100/200 300 400).each do |level|
        select_menu(custom_id: "role_add_#{level}") do |event|
          # add disciple role here to allow access to server
          event.user.add_role(CONFIG['roles']['disciple'])

          # add requested roles from dropdown to user
          event.values.each { |role_id| event.user.add_role role_id } # rubocop:disable Style/HashEachMethods

          event.respond(ephemeral: true) do |builder|
            builder.add_embed do |embed|
              embed.description = "✅ Added #{event.values.size} #{level}-level role#{'s' if event.values.size > 1}"
              embed.color = CONFIG['colors']['success']
            end
          end
        end
      end

      application_command(:role).subcommand(:remove) do |event|
        event.respond(ephemeral: true) do |builder, view|
          # figure out what class roles the user has
          common_roles = event.user.roles.map(&:id) & ROLES.values

          if common_roles.empty?
            builder.add_embed do |embed|
              embed.fields = [
                { name: "You don't have any roles to remove!", value: 'Add some roles with `/role add`' }
              ]
              embed.color = CONFIG['colors']['warn']
            end
            next
          end

          builder.add_embed do |embed|
            embed.fields = [
              { name: 'Role Selection', value: 'Select roles to remove in the dropdown below:' }
            ]
            embed.color = CONFIG['colors']['info']
          end

          view.row do |row|
            row.select_menu(custom_id: 'role_remove', placeholder: 'Select roles!',
                            max_values: common_roles.size) do |s|
              common_roles.each do |id|
                s.option(label: ROLES.key(id).upcase, value: id.to_s)
              end
            end
          end
        end
      end

      select_menu(custom_id: 'role_remove') do |event|
        # remove requested roles from dropdown to user
        event.values.each { |role_id| event.user.remove_role role_id } # rubocop:disable Style/HashEachMethods

        event.update_message(ephemeral: true) do |builder|
          builder.add_embed do |embed|
            embed.description = "✅ Removed #{event.values.size} roles"
            embed.color = CONFIG['colors']['success']
          end
        end
      end
    end
  end
end
