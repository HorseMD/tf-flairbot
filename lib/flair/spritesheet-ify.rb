%w[RMagick fileutils net/https uri yaml].each { |m| require m }
require './flair/tinypng_upload.rb'
include Magick

# Stitches all the images together into one spritesheet and creates the CSS for them.
class SpritesheetIfy
  attr_accessor :images_dir
  attr_accessor :image_size

  def initialize img_maxsize=25, images_dir, output_dir
    @image_size = img_maxsize
    @images_dir = images_dir

    FileUtils.mkdir_p output_dir unless File.directory? output_dir

    images = get_images_as_list(@images_dir)
    write_css(images, "#{output_dir}/spritesheet.css", "flair")

    imagelist = ImageList.new(*images)
    stitch_spritesheet(imagelist, "#{output_dir}/spritesheet_uncompressed.png")
  end

  # Given a TinyPNG API key, compress the spritesheet within the given directory.
  def compress api_key, path
    TinyPNGUpload.key = api_key
    TinyPNGUpload.upload("#{path}/spritesheet_uncompressed.png", "#{path}/spritesheet.png")    
  end

  private
    # Looks in the given directory for images, returns a sorted array of them.
    def get_images_as_list dir
      images = Dir.glob("#{dir}/*.png").map(&File.method(:realpath))
      images.sort!
    end

    # Writes the CSS for the spritesheet.
    def write_css images, css_file, prefix
      open(css_file, 'a') do |f|
        f.puts ".#{prefix} {width: #{@image_size}px; height: #{@image_size}px;}"
      end

      count = 0
      images.each do |item|
        image          = Image.read(item).first
        item           = File.basename(item)
        sanitized_name = item.gsub(/[^a-zA-Z0-9]/, '').sub('png', '')

        image_identifier = "background-position: 0 #{-(count * @image_size)}px;"

        open(css_file, 'a') do |f|
          f.puts ".#{prefix}-#{sanitized_name} { #{image_identifier} }"
        end
        count += 1;
      end
    end

    # Sitches all the images together into one spritesheet.
    def stitch_spritesheet images, file
      geometry = "#{@image_size}x#{@image_size}"
      montage  = images.montage {
        self.tile             = "1x"
        self.border_width     = 0
        self.geometry         = geometry
        self.background_color = "Transparent"
      }
      montage.write(file)
    end
end

if __FILE__ == $0
  SpritesheetIfy.new 25, "#{File.dirname(__FILE__)}/tmp/hat_images"
end

