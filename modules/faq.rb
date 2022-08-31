require 'yaml'

module Bishop
  module Modules
    module Faq
      extend Discordrb::Commands::CommandContainer

      command(:faq) do |event, slug, *message|
        faqs = YAML.parse_file('faq.yml')

        # handle add/remove for admins only
        case slug
        when 'register', 'new', 'add'
          return unless event.author.roles.intersect? CONFIG['roles']['admin']

          faqs[slug] = message.join(' ')
          File.write('faq.yml', faqs.to_yaml)
        when 'delete', 'remove'
          return unless event.author.roles.intersect? CONFIG['roles']['admin']

          faqs.delete slug
          File.write('faq.yml', faqs.to_yaml)
        end

        case
        when faqs[slug]
          event.send_embed do |embed|
            event.color = CONFIG['colors']['info']
            embed.fields = [
              { name: "FAQ: #{slug}", value: faqs[slug] },
            ]
          end
        when slug
          # bad slug given
          event.message.react '❓'
        else
          # list if no slug
          event.send_embed do |embed|
            embed.color = CONFIG['colors']['info']
            embed.fields = [
              { name: "All FAQs", value: faqs.keys.join " " },
            ]
          end
        end
      end
    end
  end
end
