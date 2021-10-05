# frozen_string_literal: true

require 'mathematical'
require 'mini_magick'

module LatexRenderer
  # Renders the latex equation contained in `equation` as a PNG to `file`.
  # @param file [File] The file to render the equation to.
  #   Must already exist, as this does not set a filename!
  # @param equation [String] The equation to render.

  def self.render_latex_equation(file, equation)
    raw_image = Mathematical.new(format: :png, ppi: 500.0).render(
      equation.gsub(/(`|```(tex)?)/, '') # remove any `s from code block
              .gsub('\\\\', '\\') # prevent double backslash, needed to make latex rendering work
              .strip
    )

    raise raw_image[:exception] if raw_image[:exception]

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
end
