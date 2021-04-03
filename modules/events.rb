# frozen_string_literal: true

module EventHandlers
  extend Discordrb::EventContainer

  message do |event|
    # :pray: to the God King (praise be btw)
    event.message.react '🙏' if event.author.roles.any? { |r| r.id == CONFIG['roles']['god'] }

    # react :zachR: and :zachL: react to the eggman (but not in class channels)
    if event.author.id == 199396039357104128 && !(CONFIG['class_categories'].value? event.channel.parent_id)
      event.message.react ':zachL:797961331101794344'
      event.message.react ':zachR:797961330929303583'
    end

    # render any latex math equations in message
    equations = event.message.content.scan(/(?:^|\s)\$(.+?)\$(?:$|\s)/).flatten
    equations.each do |eqn|
      Tempfile.create(%w(equation png)) do |tempfile|
        tempfile.binmode
        render_latex_equation(tempfile, eqn)
        event.send_file(tempfile, filename: 'equation.png')
      end
    end
  end

  # add disciple role on member join
  member_join do |event|
    event.server.member(event.user.id).add_role(CONFIG['roles']['disciple'])
  end
end
