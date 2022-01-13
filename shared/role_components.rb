# frozen_string_literal: true

module RoleComponentBuilder
  def self.role_add_selects(embed, view)
    embed.fields = [
      { name: 'Role Selection', value: "Select roles in the dropdowns below:\n(sorted by class number)" }
    ]
    embed.color = CONFIG['colors']['info']

    # since max of 25 choices per dropdown, break up by level
    view.row do |row|
      # general roles (not class)
      r = ROLES.filter { |n, _| n.match?(/^\D+$/) }
      row.select_menu(custom_id: 'role_add_general', placeholder: 'General roles', max_values: r.size) do |s|
        r.each do |role, id|
          s.option(label: role.capitalize, value: id.to_s)
        end
      end
    end
    view.row do |row|
      # 100/200 level
      r = ROLES.filter { |n, _| n.match?(/[12]\d\d/) }
      row.select_menu(custom_id: 'role_add_100/200', placeholder: '100/200-level classes',
                      max_values: r.size) do |s|
        r.each do |role, id|
          s.option(label: role.upcase, value: id.to_s)
        end
      end
    end
    view.row do |row|
      # 300 level
      r = ROLES.filter { |n, _| n.match?(/3\d\d/) }
      row.select_menu(custom_id: 'role_add_300', placeholder: '300-level classes', max_values: r.size) do |s|
        r.each do |role, id|
          s.option(label: role.upcase, value: id.to_s)
        end
      end
    end
    view.row do |row|
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
