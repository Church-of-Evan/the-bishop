# frozen_string_literal: true

module SlashCommands
  extend Discordrb::EventContainer

  def self.register_commands(bot)
    puts 'registering command role'
    bot.register_application_command(:role, 'Manage your class roles', server_id: ENV['SERVER_ID']) do |cmd|
      cmd.subcommand(:add, 'Give yourself class roles')
      cmd.subcommand(:remove, 'Remove class roles from yourself')
      cmd.subcommand(:list, 'List all valid class roles')
    end
  end

  application_command(:role).subcommand(:list) do |event|
    event.respond ephemeral: true do |builder|
      builder.add_embed do |embed|
        embed.fields = [
          { name: 'Valid roles:', value: "`#{ROLES.keys.map { |k| k.ljust 7 }.join('` `')}`" },
          { name: 'Missing a class?', value: 'If we are missing a class, let us know and we will add a channel!' }
        ]
        embed.color = CONFIG['colors']['error']
      end
    end
  end

  application_command(:role).subcommand(:add) do |event|
    event.respond(ephemeral: true) do |builder, components|
      builder.add_embed do |embed|
        embed.fields = [
          { name: 'Role Selection', value: "Select roles in the dropdown below:\n(sorted by class number)" }
        ]
        embed.color = CONFIG['colors']['info']
      end

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
        row.select_menu(custom_id: 'role_add_100/200', placeholder: '100/200-level classes', max_values: r.size) do |s|
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

  %w(general 100/200 300 400).each do |level|
    select_menu(custom_id: "role_add_#{level}") do |event|
      # add disciple role here to allow access to server
      event.user.add_role(CONFIG['roles']['disciple'])

      # add requested roles from dropdown to user
      event.values.each do |role_id| # rubocop:disable Style/HashEachMethods
        event.user.add_role role_id
      end

      event.respond(ephemeral: true) do |builder|
        builder.add_embed do |embed|
          embed.description = "✅ Added #{event.values.size} #{level}-level roles"
          embed.color = CONFIG['colors']['success']
        end
      end
    end
  end

  application_command(:role).subcommand(:remove) do |event|
    event.respond(ephemeral: true) do |builder, components|
      # figure out what class roles the user has
      common_r = event.user.roles.map(&:id) & ROLES.values

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

      components.row do |row|
        row.select_menu(custom_id: 'role_remove', placeholder: 'Select roles!', max_values: common_r.size) do |s|
          common_r.each do |id|
            s.option(label: ROLES.key(id).upcase, value: id.to_s)
          end
        end
      end
    end
  end

  select_menu(custom_id: 'role_remove') do |event|
    # remove requested roles from dropdown to user
    event.values.each do |role_id| # rubocop:disable Style/HashEachMethods
      event.user.remove_role role_id
    end

    event.update_message(ephemeral: true) do |builder|
      builder.add_embed do |embed|
        embed.description = "✅ Removed #{event.values.size} roles"
        embed.color = CONFIG['colors']['success']
      end
    end
  end
end
