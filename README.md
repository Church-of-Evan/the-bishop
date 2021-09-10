# The Bishop bot

Discord bot for a server I run. Does joke things and role moderation.

## Setup

1. Install Ruby and Bundler
2. Copy `config.example.yml` to `config.yml`
3. Replace the placeholder token
4. Copy `roles.example.yml` to `roles.yml`
5. Add the desired `role: roleID` pairs to `roles.yml`
6. Install Mathematical gem dependencies:
   -  `pacman -Sy cmake base-devel python libffi libxml2 gdk-pixbuf2 cairo pango jbigkit`
   -  `apt install cmake build-essential bison flex libffi-dev libxml2-dev libgdk-pixbuf2.0-dev libcairo2-dev libpango1.0-dev`
7. Install required gems: `bundle install`
8. Run the bot: `bundle exec ruby main.rb`

**Note:** if LaTeX equations are rendering weirdly, install the [missing fonts](https://github.com/gjtorikian/mathematical#fonts-and-special-notices-for-mac-os-x):

```sh
$ cd ~/.fonts
$ curl -LO http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/cmex10.ttf \
    -LO http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/cmmi10.ttf \
    -LO http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/cmr10.ttf \
    -LO http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/cmsy10.ttf \
    -LO http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/esint10.ttf \
    -LO http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/eufm10.ttf \
    -LO http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/msam10.ttf \
    -LO http://mirrors.ctan.org/fonts/cm/ps-type1/bakoma/ttf/msbm10.ttf
```

-----

*Created by [detjensrobert](https://github.com/detjensrobert) / @WholeWheatBagels#3140*
