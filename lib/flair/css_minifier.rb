%w[net/https uri].each { |m| require m }

class CSSMinifier

  # Given a CSS file, read it, send it to http://cssminifier.com, and replace
  # the contents of the old CSS file with the new, minified version.
  def self.minify input
    uri      = URI.parse('http://cssminifier.com/raw')
    response = Net::HTTP.post_form(uri, {"input" => IO.read(input)})

    File.open(input, 'w') { |file| file.write(response.body) }
  end
end
