%w[redditkit yaml json].each { |m| require m }

class Flairbot
  attr_accessor :client
  attr_accessor :subreddit
  attr_accessor :maintainer

  def initialize sub, username, password, maintainer
    @client            = RedditKit::Client.new username, password
    @client.user_agent = "TF2 Flairbot v1.0"
    @subreddit         = sub
    @maintainer        = maintainer
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
      parse_message(message) if message.is_a? RedditKit::PrivateMessage
    end
  end

  # Parse a single message for flair updating etc...
  def parse_message message
    @client.mark_as_read message

    if message.subject.downcase.eql? "flair"
      result = update_flair(message.author, message.body, valid_flairs)

      if result.is_a? FlairFail
        @client.send_message(get_error_message(message.author, result), message.author, :subject => "There was an error with setting your flair.")
        puts "Error: #{result.message}"
      else
        @client.send_message(get_message(message.author, message.body), message.author, :subject => "Flair updated.")
        puts "Success! Flair for #{message.author} set to #{message.body}."
      end
    elsif message.subject.downcase.eql? "stop" and message.author == @maintainer
      puts "Received stop message from #{message.author}."
      sign_out
      exit
    else
      @client.send_message(get_unexpected_message(message.author), message.author, :subject => "re: #{message.subject}")
      puts "Recieved unexpected message: #{message.body} from #{message.author}."
    end
  end

  # Sign out from Reddit.
  def sign_out
    @client.sign_out
  end

  private
  # Get the pretty success message for the given author.
  def get_message author, flair
    "Hello #{author},\n\nI just wanted to let you know that I have completed your request to use the flair \"#{flair}\", "\
    "and your flair should now be updated.\n\nYou may need to refresh your browser cache before you see any changes: "\
    "This is usually done by pressing the Shift key while refreshing."
  end

  # Get the pretty error message for the given author, with the given error.
  def get_error_message author, error
    "Hello #{author},\n\nUnfortunately there was an error when processing your flair request:\n"\
    " >#{error.message}.\n\nPlease wait a little while, and try again later."\
    " If the problem persists, please contact a moderator and copy this message to them."
  end

  # When the bot gets a message it's not expecting, let the sender of the message know that this is
  # actually a robot and that they should contact the maintainer.
  def get_unexpected_message author
    "Hello #{author},\n\nJust so you know, I am a robot and have no idea what your message means. If you have any queries, "\
    "please contact my maintainer, [#{@maintainer}](http://reddit.com/u/#{maintainer})."
  end

  # Sets the given user's flair to the given flair, by classname.
  def update_flair user, flair, valid_flairs
    return FlairFail.new "#{flair} is not an existing flair" unless valid_flairs.include? flair

    begin
      @client.set_flair({ :subreddit => @subreddit, :css_class => flair, :user => user })
    rescue RedditKit::TooManyClassNames
      FlairFail.new "There are too many flairs!"
    rescue Exception => e
      FlairFail.new e.message
    end
  end
end

class FlairFail < StandardError
end

if __FILE__ == $0
  cfg           = YAML.load_file("#{File.dirname(__FILE__)}/../config.yml")["bot"]
  sleep_time    = cfg["refresh_rate"]
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
