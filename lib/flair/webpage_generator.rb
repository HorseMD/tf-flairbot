require 'fileutils'
require 'json'

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

    dir = @output_dir #"#{File.dirname(__FILE__)}/out/website"
    create_unless_exist dir
    create_unless_exist "#{dir}/style"
    create_unless_exist "#{dir}/js"

    File.write("#{dir}/index.html", contents)
    File.write("#{dir}/style/flairstyle.css", css)
    File.write("#{dir}/js/names.js", "names = " + names.to_json)
    File.write("#{dir}/js/flairedirect.js", get_message_js)
    File.write("#{dir}/js/search.js", get_search_js)

    FileUtils.cp(spritesheet, "#{dir}/style")
    FileUtils.cp_r("#{input}/style/.", "#{dir}/style")
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

    def get_search_js
"function updateFlairList(txtbox) {
    var count = Object.keys(names).length;
    for(var i=0; i<count; i++) {
        if(names[i].toLowerCase().indexOf(txtbox.value.toLowerCase().replace(/\s/g, '')) <= -1) {
            document.getElementById(i).style.display = \"none\";
        }
        else {
            document.getElementById(i).style.display = \"inline-block\";
        }
    }
}"
    end
end

