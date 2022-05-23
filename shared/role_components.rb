# frozen_string_literal: true

module SharedRoleComponents
  def self.make_list_embed(embed)
    embed.fields = [
      { name: 'Missing a class?', value: 'If we are missing a class, let us know and we will add a channel!' },
      { name: 'General roles:', value: "`#{ROLES['general'].keys.join('` `')}`" },
      { name: 'Class roles:', value: "`#{ROLES['classes'].keys.map { |k| k.ljust 7 }.join('` `')}`" },
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

  def self.add_selects(embed, view)
    embed.fields = [
      { name: 'Role Selection', value: "Select roles in the dropdowns below:\n(sorted by class number)" }
    ]
    embed.color = CONFIG['colors']['info']

    # since max of 25 choices per dropdown, break up by level
    view.row do |row|
      # general roles (not class)
      r = ROLES['general']
      row.select_menu(custom_id: 'role_add_general', placeholder: 'General roles', max_values: r.size) do |s|
        r.each do |_slug, data|
          s.option(label: data['title'], value: data['id'].to_s)
        end
      end
    end

    view.row do |row|
      # 100/200 level
      r = ROLES['classes'].filter { |n, _| n.match?(/[12]\d\d/) }
      row.select_menu(custom_id: 'role_add_100/200', placeholder: '100/200-level classes', max_values: r.size) do |s|
        r.each do |slug, data|
          s.option(label: "#{slug.upcase}: #{data['title']}", value: data['id'].to_s)
        end
      end
    end

    view.row do |row|
      # 300 level
      r = ROLES['classes'].filter { |n, _| n.match?(/3\d\d/) }
      row.select_menu(custom_id: 'role_add_300', placeholder: '300-level classes', max_values: r.size) do |s|
        r.each do |slug, data|
          s.option(label: "#{slug.upcase}: #{data['title']}", value: data['id'].to_s)
        end
      end
    end

    view.row do |row|
      # 400 level
      r = ROLES['classes'].filter { |n, _| n.match?(/4\d\d/) }
      row.select_menu(custom_id: 'role_add_400', placeholder: '400-level classes', max_values: r.size) do |s|
        r.each do |slug, data|
          s.option(label: "#{slug.upcase}: #{data['title']}", value: data['id'].to_s)
        end
      end
    end

    view.row do |row|
      # 500 level
      r = ROLES['classes'].filter { |n, _| n.match?(/5\d\d/) }
      row.select_menu(custom_id: 'role_add_500', placeholder: '500-level classes', max_values: r.size) do |s|
        r.each do |slug, data|
          s.option(label: "#{slug.upcase}: #{data['title']}", value: data['id'].to_s)
        end
      end
    end
  end
end
