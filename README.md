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

6. Do the following:

Place a copy of the contents of `./generated/out/website` wherever you want to host the website (I like
to use my Dropbox's 'Public' folder).

You'll then need to minify the CSS in `./generated/out/spritesheet.css` (as Reddit limits how big this can be) and
add it to your subreddit's CSS. Note: because there are *so many hats* (about a thousand) you may have issues with your
subreddit's CSS being too large. In this case, try minifying the entire stylesheet for your subreddit. If this fails,
bug me and I'll make a fix.

You'll also want to prepend the hat CSS with something like this:

```css
.flair {
    border: none !important;
    top: 20px;
    padding: 0px;
    background: url(%%spritesheet%%);
    display: inline-block;
    width: 25px;
    height: 25px;
    vertical-align: middle;
}
```

You'll also need to upload `spritesheet.png` into your subreddit's images. You'll also probably want
to place a link to wherever you are hosting the flair website.

Finally, you can run the flair bot!

Flairbot:
```ruby
ruby flairbot.rb
```

##TODO

* Logging
* Bot should validate the flairs its asked for

