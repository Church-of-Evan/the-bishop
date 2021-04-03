# frozen_string_literal: true

module EventHandlers
  extend Discordrb::EventContainer

  # add :pray: react to the God King (praise be btw) and :zachR: and :zachL: react to Toxic_Z
  message do |event|
    event.message.react '🙏' if event.author.roles.any? { |r| r.id == CONFIG['roles']['god'] }

    if event.author.id == 199396039357104128 && !(CONFIG['class_categories'].value? event.channel.parent_id)
      event.message.react ':zachL:797961331101794344'
      event.message.react ':zachR:797961330929303583'
    end
  end

  # add disciple role on member join
  member_join do |event|
    event.server.member(event.user.id).add_role(CONFIG['roles']['disciple'])
  end
end
