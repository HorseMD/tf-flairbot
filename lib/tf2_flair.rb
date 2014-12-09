%w[downloader spritesheet-ify webpage_generator].each { |rel| require_relative "flair/#{rel}" }

class TF2Flair
  def initialize
    gen_dir = "#{File.dirname(__FILE__)}/../generated"    
    urls = "#{gen_dir}/resources/urls.json"
    
    cfg = YAML.load_file('../config.yml')
    sprite_size = cfg["settings"]["sprite_size"]

    puts "Downloading from #{urls}"    
    downloader = Downloader.new(urls, "#{gen_dir}/tmp/hat_images")
    downloader.fetch
    downloader.resize(sprite_size, sprite_size)

    puts "Stitching images and creating spritesheet with CSS"
    spriter = SpritesheetIfy.new sprite_size, "#{gen_dir}/tmp/hat_images", "#{gen_dir}/out/spritesheet"
    spriter.compress cfg["api"]["tinypng"], "#{gen_dir}/out/spritesheet"

    puts "Generating website"
    generator = WebpageGenerator.new cfg["bot"]["username"], "#{gen_dir}/out/website"
    html, css, names = generator.generate_flair_html "#{gen_dir}/tmp/hat_images"
    generator.update_flair_website(
      html, css, names,
      "#{gen_dir}/resources/website",
      "#{gen_dir}/out/spritesheet/spritesheet.png"
    )
  end
end

if __FILE__ == $0
  TF2Flair.new
end
