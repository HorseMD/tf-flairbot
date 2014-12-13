%w[fileutils json].each { |m| require m }

class WebpageGenerator
  attr_accessor :username
  attr_accessor :output_dir

  def initialize username, out
    @name = username
    @output_dir = out
  end

  # Generate the html, css and javascript for the website.
  def generate_flair_html imagedir
    images = Dir.entries(imagedir)
    images.delete_if { |item| not item.include? ".png" }
    images.sort!

    html  = []
    css   = []
    names = {}
    html << "<ul class=\"flairlist\">"

    images.each_with_index do |item, count|
      sanitized_name = item.sub('.png', '')
      sanitized_name.gsub!(/[^a-zA-Z0-9]/, '')
      names["#{count}"] = sanitized_name

      html << "<li id=\"#{count}\" class=\"flair-#{count}\"></li>"
      css  << ".flair-#{count} {background-position: 0 -#{count * 25}px;}"
    end

    html << "</ul>"
    return html.join(""), css.join(""), names
  end

  # Given a string of HTML, CSS, a hashmap of hat names and the website template,
  # create a website based on this.
  def update_flair_website html, css, names, input, spritesheet
    contents = File.read("#{input}/website_template.html")
    contents.sub!("%FLAIRS%", html)

    create_unless_exist @output_dir
    create_unless_exist "#{@output_dir}/style"
    create_unless_exist "#{@output_dir}/js"

    File.write("#{@output_dir}/index.html", contents)
    File.write("#{@output_dir}/style/flairstyle.css", css)
    File.write("#{@output_dir}/js/names.js", "names = " + names.to_json)
    File.write("#{@output_dir}/js/flairedirect.js", get_message_js)

    FileUtils.cp(spritesheet, "#{@output_dir}/style")
    FileUtils.cp_r("#{input}/js/.", "#{@output_dir}/js/")
    FileUtils.cp_r("#{input}/style/.", "#{@output_dir}/style")
  end

  private
    def create_unless_exist dir
      FileUtils.mkdir_p dir unless File.directory? dir
    end

    def get_message_js
"var link = \"http://reddit.com/message/compose/?to=#{@name}&amp;subject=flair&amp;message=\"
    document.addEventListener('click', function(e) {
    if (e.target.className.indexOf(\"flair-\") > -1 && e.target.id != \"undefined\") {
        window.open(link + names[e.target.id])
    }
});"
    end
end
