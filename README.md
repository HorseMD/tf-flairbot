#TF2 Flair Generator / Bot

Downloads all the TF2 cosmetic items and sets them up to be used
as flair for subreddits.

Also generates a website for the flair, as Reddit has a limit on how many
flairs the flair menu can have in it (so one needs a bot to set the flairs
pseudomanually).

##Prerequisites

You will need ImageMagick installed on the system that this runs on.
For linux-based systems, simply use your package manager to install imagemagick.

You will also need the development headers for ImageMagick, on Linux this is `libmagickwand-dev`.

##Usage

1. Copy `config_sample.yml` to `config.yml`.
2. Update the data in `config.yml` with the settings relevant to you (subreddit, bot authentication, etc...).
3. Run `bundle` inside the root of this directory.
4. Generate everything at least once (this will make the `./generated/out` and `./generated/tmp` folders + their data).

Spritesheet, CSS and website generation:
```shell
ruby tf2_flair.rb
```

After that, do the following:

1. Place a copy of the contents of `./generated/out/website` wherever you want to host the website (I like
to use my Dropbox's 'Public' folder).
2. Upload `./generated/out/spritesheet/spritesheet.png` to your subreddit's images.
3. You should then copy the contents of `./generated/out/spritesheet/spritesheet.css` into your subreddit's stylesheet.
4. After that, you'll want to prepend the CSS with something like this (don't forget to update the width and height if you
changed them in `config.yml`.):

```css
.flair {
    border: none !important;
    top: 20px;
    padding: 0px;
    background: url(%%spritesheet%%);
    display: inline-block;
    width: 28px;
    height: 28px;
    vertical-align: middle;
}
```

You'll also probably want to place a link on your subreddit to wherever you are hosting the flair website.

Finally, you can run the flair bot!

```shell
ruby flairbot.rb
```

##Configuration

You can customise most aspects of the bot and flair/website generation via `config.yml` in the root
of this project.

You can customise the messages the bot replies with by editing the files within `./generated/resources/bot`.
The contents of these files should be [Reddit-compatible](https://www.reddit.com/comments/6ewgt/reddit_markdown_primer_or_how_do_you_do_all_that)
markdown. The flair bot will search and replace variables within these files.

###Variables

* %AUTHOR%     - the person who sent a message to the bot.
* %BODY%       - the body of the message sent to the bot.
* %MAINTAINER% - the person (set in `config.yml`, the person who is maintaining the bot).
* %SUBJECT%    - the subject of the message sent to the bot.
* %SUBREDDIT%  - the subreddit this bot is managing.
* %INFO%       - misc info that changes based on the response-type. E.g. for `success.md`, this will be the name of the flair. For `failure.md`,
this is the error message.

##TODO

* Logging (though arguably one could say it's logs are it's sent and recieved messages on Reddit).

