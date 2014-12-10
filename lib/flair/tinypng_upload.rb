%w[net/https uri].each { |m| require m }

# Adapted from https://tinypng.com/developers/reference#ruby
class TinyPNGUpload
  @@key = ""

  def self.upload input, output
    raise "Error, please set the API key for TinyPNG." unless @@key != ""
    uri          = URI.parse('https://api.tinypng.com/shrink')
    http         = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request.basic_auth("api", @@key)

    response = http.request(request, File.binread(input))
    if response.code == "201"
      File.binwrite(output, http.get(response["location"]).body)
    else
      puts "Compression failed (error #{response.code})."
    end
  end

  def self.key= k
    @@key = k
  end
end
