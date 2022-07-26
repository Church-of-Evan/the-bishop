# The Bishop bot

Discord bot for a server I run. Does joke things and role moderation.

## Setup

1. Copy `config.example.yml` to `config.yml`
2. Replace the placeholder token
3. Copy `roles.example.yml` to `roles.yml`
4. Add the desired `rolename: roleid` pairs to `roles.yml`

## Run with Docker

```sh
# build image
docker build -t detjensrobert/the-bishop .
# run container as daemon with config files
docker run -d --rm --name the-bishop -v $(pwd)/config.yml:/app/config.yml \
   -v $(pwd)/roles.yml:/app/roles.yml detjensrobert/the-bishop
```

## Run locally

1. Install Mathematical gem dependencies:
   - `pacman -Sy cmake base-devel python libffi libxml2 gdk-pixbuf2 cairo pango jbigkit`
   - `dnf install ruby-devel gcc-c++ cmake bison flex libffi-devel libxml2-devel glib2-devel cairo-devel cairo-gobject-devel pango-devel gdk-pixbuf2-devel jbigkit-devel libwebp-devel`
   - `apt install cmake build-essential bison flex libffi-dev libxml2-dev libgdk-pixbuf2.0-dev libcairo2-dev libpango1.0-dev fonts-lyx`
2. Install required gems: `bundle install`
3. Run the bot: `bundle exec ruby main.rb`

## Contributing

PRs welcome! DiscordRB is not hard to use, and their [documentation](https://drb.shardlab.dev) has great [examples](https://github.com/shardlab/discordrb/tree/main/examples).

-----

*Created by [detjensrobert](https://github.com/detjensrobert) / @WholeWheatBagels#3140*
