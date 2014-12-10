%w[redditkit yaml json].each { |m| require m }

class Flairbot
  attr_accessor :client
  attr_accessor :subreddit
  attr_accessor :maintainer

  @@resources = "#{File.dirname(__FILE__)}/../generated/resources/bot/"
  @@responses = {}

  def initialize sub, username, password, maintainer
    @client            = RedditKit::Client.new username, password
    @client.user_agent = "TF2 Flairbot v1.0"
    @subreddit         = sub
    @maintainer        = maintainer

    preload_responses

    throw ArgumentError, "Invalid credentials"  unless @client.signed_in?
    throw ArgumentError, "Bot isnt a moderator" unless @client.subreddit(@subreddit).user_is_moderator?
  end

  # Go through the unread messages and update everyones flairs.
  # If the message subject is "flair", then we're updating a flair.
  # Otherwise if its subject is "stop", and the user is the maintainer of this bot,
  # then we will stop the bot.
  def poll_messages valid_flairs
    unread_messages = @client.messages({:category => :unread})
    unread_messages.each do |message|
      parse_message(message, valid_flairs) if message.is_a? RedditKit::PrivateMessage
    end
  end

  # Parse a single message for flair updating etc...
  # Once it's parsed, the message is marked as having been read.
  def parse_message message, valid_flairs
    data = {
      :subject    => message.subject,
      :body       => message.body,
      :author     => message.author,
      :maintainer => @maintainer,
      :subreddit  => @subreddit
    }

    if message.subject.downcase.eql? "flair"
      result = update_flair(message.author, message.body, valid_flairs)

      if result.is_a? FlairFail
        reply = load_response("failure", data.merge(:info => result.message))
        @client.send_message(reply, message.author, :subject => "There was an error with setting your flair.")
      else
        reply = load_response("success", data.merge(:info => message.body))
        @client.send_message(reply, message.author, :subject => "Flair updated.")
      end
    elsif message.subject.downcase.eql? "stop" and message.author == @maintainer
      @client.sign_out
      exit
    else
      @client.send_message(load_response("unexpected", data), message.author, :subject => "re: #{message.subject}")
    end

    @client.mark_as_read message
  end

  def self.resources= path
    @@resources = path
  end

  private
  # Read each of the bot's resources into @@resources so we don't need to read from file
  # more than once.
  def preload_responses
    raise "Resource path for Flairbot hasn't been set. Please set it via Flairbot.reponses = <path>." unless not @@resources.nil?

    Dir.foreach(@@resources) do |file|
      next if file.start_with? '.' or file.end_with? "~"
      @@responses[File.basename(file, File.extname(file))] = IO.read(@@resources + file)
    end
  end

  # Sets the given user's flair to the given flair, by classname.
  def update_flair user, flair, valid_flairs
    return FlairFail.new "\"#{flair}\" is not an existing flair." unless valid_flairs.include? flair

    begin
      @client.set_flair({ :subreddit => @subreddit, :css_class => flair, :user => user })
    rescue RedditKit::TooManyClassNames
      FlairFail.new "There are too many flairs!"
    rescue Exception => e
      FlairFail.new e.message
    end
  end

  # Generate the response message this bot will send.
  # response - the name of the response e.g. "success"
  # opts - Hash containing keys to be replaced with values.
  def load_response response, opts={}
    txt = @@responses[response]
    opts.each do |key, val|
      txt.gsub!("%#{key.upcase}%", val)
    end
    return txt
  end
end

class FlairFail < StandardError
end

if __FILE__ == $0
  cfg        = YAML.load_file("#{File.dirname(__FILE__)}/../config.yml")["bot"]
  sleep_time = cfg["refresh_rate"]
  begin
    valid_flairs = JSON.parse(
      File.read("#{File.dirname(__FILE__)}/../generated/out/website/js/names.js").sub('names = ', '')
    ).values
  rescue Exception => e
    puts "Failed to load valid flairs: #{e.message}"
  end

  bot = Flairbot.new cfg["subreddit"], cfg["username"], cfg["password"], cfg["maintainer"]
  loop do
    begin
      bot.poll_messages valid_flairs
    rescue RedditKit::RequestError => e
      puts e.message
    rescue RedditKit::TimedOut => e
      puts "Connection timed out."
    rescue Exception => e
      puts e.message
    end
    sleep sleep_time
  end
  bot.sign_out
end
