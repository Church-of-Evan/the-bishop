# frozen_string_literal: true

require_relative '../shared/latex_renderer'
require 'math-to-itex'

module EvanBot
  module Modules
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
        MathToItex(event.message.content).convert do |eqn|
          Discordrb::LOGGER.info "rendering equation from event: #{eqn}"

          Tempfile.create(%w(equation png)) do |tempfile|
            tempfile.binmode
            begin
              LatexRenderer.render_latex_equation(tempfile, eqn)
              event.send_file(tempfile, filename: 'equation.png')
            rescue StandardError => e
              event.send_embed do |embed|
                embed.color = CONFIG['colors']['error']
                embed.title = 'Error rendering equation'
                embed.description = "```\n#{e}\n```"
              end
            end
          end
        end

        nil
      end
    end
  end
end
