# The Bishop bot

Discord bot for a server I run. Does joke things and role moderation.

## Setup

1. Copy `config.example.yml` to `config.yml`
2. Replace the placeholder token
3. Copy `roles.example.yml` to `roles.yml`
4. Add the desired `rolename: roleid` pairs to `roles.yml`

## Run with Docker

```sh
docker build -t the-bishop .
docker run -d the-bishop
```

## Run locally

1. Install Mathematical gem dependencies:
   -  `pacman -Sy cmake base-devel python libffi libxml2 gdk-pixbuf2 cairo pango jbigkit`
   -  `apt install cmake build-essential bison flex libffi-dev libxml2-dev libgdk-pixbuf2.0-dev libcairo2-dev libpango1.0-dev fonts-lyx`
2. Install required gems: `bundle install`
3. Run the bot: `bundle exec ruby main.rb`

-----

*Created by [detjensrobert](https://github.com/detjensrobert) / @WholeWheatBagels#3140*
