# frozen_string_literal: true

require 'mathematical'
require 'mini_magick'

# Renders the latex equation contained in `equation` as a PNG to `file`.
# @param file [File] The file to render the equation to.
#   Must already exist, as this does not set a filename!
# @param equation [String] The equation to render.
#   Enclosing $s should not be passed in.
def render_latex_equation(file, equation)
  eqn_filters = [
    ['```tex', ''], # remove any `s for code block
    ['`', ''], # remove any `s for code block
    # ['\\text{', '\\backslash text~{'], # \text mode bogs down system
    ['\\\\', '\\'], # prevent double backslash, needed to make latex rendering work
    ['$', '\\$'] # $ is to enter/exit math mode but already in math mode so ignore
  ]
  eqn_filters.each { |from, to| equation.gsub!(from, to) }
  equation.strip!

  raw_image = Mathematical.new(format: :png, ppi: 500.0).render("$#{equation}$")

  if raw_image[:exception]
    return event.send_embed do |embed|
      embed.color = CONFIG['colors']['error']
      embed.title = 'Error rendering equation'
      embed.description = "```\n#{raw_image[:exception]}\n```"
    end
  end

  file.write raw_image[:data]
  file.rewind

  MiniMagick::Image.new(file.path) do |i|
    # invert image, keeping transparency
    i.channel 'RGB'
    i.negate

    # fill transparency with discord grey
    # i.background '#36393f'
    # i.flatten
  end.write file
  file.rewind

  file
end
