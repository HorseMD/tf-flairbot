%w[fileutils nokogiri open-uri yaml RMagick].each { |mod| require mod }
include Magick

# Downloads all the TF2 cosmetics from the Team Fortress 2 Wiki.
# Also it resizes them (maintaining aspect ratio) to 25px by 25px.
class Downloader
  attr_accessor :image_dir
  attr_accessor :urls

  def initialize url_location, image_dir
    @urls      = YAML.load_file(url_location)
    @image_dir = image_dir

    FileUtils.mkdir_p(@image_dir) unless File.directory? @image_dir
  end

  # Download all the hat images. All of them.
  def fetch
    puts "Downloading images to #{@image_dir}"

    @urls.each do |key, url|
      #skip to next url if something goes wrong
      response = open(url) rescue nil
      next unless response

      images = Nokogiri::HTML(response).css("table img")
      puts "Downloading #{images.count} #{key} items from #{url}"

      images.each do |image|
        download_and_save(image, @image_dir)
      end
    end
  end

  # Trim the image to make it as small as possible without affecting its colors
  # Then resize it
  def resize width, height
    puts "Resizing images to #{width}x#{height}"
    Dir.glob("#{@image_dir}/*.png") do |item|
      image = Image.read(item).first
      image.trim!
      # now the image has been autocropped, we just need to resize it.
      image.resize_to_fit!(width, height) unless image.columns < width and image.rows < height
      # and now we write it to file!
      if image.changed?
        File.open(item, 'w') { |f| f << image.to_blob } # change item to a new path if you don't want to overwrite
        puts "\t + Resized #{item}"
      else
        puts "\t - #{image} unchanged, no changes to save."
      end
    end
  end

  private
    # Get the pretty name of the image.
    def image_name(image)
      image.attributes['alt'].value
    end

    # Get the path of the given image.
    def image_path(dir, image)
      "#{dir}/#{image_name(image)}.png"
    end

    # Download a single image, given its HTML tag.
    def download_and_save(image, to_directory)
      if not File.exists? image_path(to_directory, image)
        puts "\t + #{image_name(image)}"
        open(image_path(to_directory, image), 'wb') do |file|
          file << open("http://wiki.teamfortress.com#{image.attributes["src"].value}").read
        end
      else
        puts "\t * Skipping download of #{image_name(image)} (already downloaded)"
      end
    end
end

