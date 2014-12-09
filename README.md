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
4. Generate everything at least once (this will make the ./generated/out and ./generated/tmp folders + their data)
5. Run the Flair bot.

Spritesheet, CSS and website generation:
```ruby
ruby tf2_flair.rb
```

Flairbot:
```ruby
ruby flairbot.rb
```

##TODO

* Logging
* Bot should validate the flairs its asked for

