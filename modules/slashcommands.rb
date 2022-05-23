# frozen_string_literal: true

require_relative '../shared/role_components'

module Bishop
  module Modules
    module SlashCommands
      extend Discordrb::EventContainer

      def self.register_commands(bot)
        Discordrb::LOGGER.info 'Registering /role'

        # if its already registered, just return and dont re-register it
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
        event.respond(ephemeral: true) do |builder|
          builder.add_embed do |embed|
            # build embed from
            SharedRoleComponents.make_list_embed(embed)
          end
        end
      end

      application_command(:role).subcommand(:add) do |event|
        event.respond(ephemeral: true) do |builder, view|
          builder.add_embed do |embed|
            SharedRoleComponents.add_selects(embed, view)
          end
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
              embed.description = "✅ Added #{event.values.size} #{level}-level role(s)"
              embed.color = CONFIG['colors']['success']
            end
          end
        end
      end

      application_command(:role).subcommand(:remove) do |event|
        # figure out what class roles the user has
        # union between user's own roles and all the roles the bot knows about
        all_roles = ROLES['general'].merge ROLES['classes']
        common_ids = event.user.roles.map(&:id) & all_roles.map { |_, r| r['id'] }

        event.respond(ephemeral: true) do |builder, view|
          if common_ids.empty?
            builder.add_embed do |embed|
              embed.fields = [
                { name: "You don't have any roles to remove!", value: 'Add some roles with `/role add`' }
              ]
              embed.color = CONFIG['colors']['warn']
            end
            next
          end

          # # truncate to the first 25 roles
          # if common_ids.size >= 25
          #   builder.add_embed do |embed|
          #     embed.fields = [
          #       { name: "You have more than 25 roles!", value: 'Only showing the first 25' }
          #     ]
          #     embed.color = CONFIG['colors']['warn']
          #   end
          # end

          builder.add_embed do |embed|
            embed.fields = [
              { name: 'Role Selection', value: 'Select roles to remove in the dropdown below:' }
            ]
            embed.color = CONFIG['colors']['info']
          end

          view.row do |row|
            row.select_menu(custom_id: 'role_remove', placeholder: 'Select roles!',
                            max_values: common_ids.size) do |s|
              common_ids.each do |id|
                role = all_roles.find { |_r, v| v['id'] == id }
                s.option(label: "#{role[0].upcase}: #{role[1]['title']}", value: id.to_s)
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
            embed.description = "✅ Removed #{event.values.size} role(s)"
            embed.color = CONFIG['colors']['success']
          end
        end
      end
    end
  end
end
