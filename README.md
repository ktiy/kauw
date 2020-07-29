# (/・・)ノ kauw window manager
kauw is an expiremental tiling window manager built for x11 using nim

currently it is but a skeleton of what's to come

## goals (・・；)
i have a few goals in mind while writing this project
- written and configured fully in [nim]
- easily configurable
- easily hackable
- be small and fairly minimalist
- help myself learn nim and get around x11

  
## development
clone using
```
$ git clone https://github.com/fox-cat/kauw
$ cd kauw
```
build using
```
$ nimble build
```
and you can test using [xephyr]
```
$ Xephyr -br -ac -noreset -screen 1920x1080 :1
$ DISPLAY=:1 ./opozzumWM
```

## TODO
see [TODO]

[nim]: https://nim-lang.org/
[xephyr]: https://wiki.archlinux.org/index.php/Xephyr
[TODO]: TODO