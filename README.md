# rctags-watcher

[![Travis CI](https://travis-ci.org/vladbalmos/rctags-watcher.svg?branch=master)](https://travis-ci.org/vladbalmos/rctags-watcher)
[![Gem Version](https://badge.fury.io/rb/rctags-watcher.svg)](https://badge.fury.io/rb/rctags-watcher)

This is a little tool which watches for file system changes on directories specified in the configuration file and then runs `ctags` to generate **tags** files in them.

## Why?
If you are using VIM and you need your **tags** file to be up to date, then this tool is for you.  
**rctags-watcher** is a GNU/Linux program written in Ruby which uses inotify to detect changes on directories and then run `ctags` to regenerate the **tags** file.

## Features
- (Re)Generate the tags file when you change source code files (saving a file in your editor of choice will do that)
- Configure which file types can trigger a tags scan
- `ctags` configuration per project (see the configuration file)

## Requirements
- GNU/Linux
- Ruby >= 2.1
- [rb-inotify](https://github.com/nex3/rb-inotify) >= 0.9.7
- [exuberant-ctags](http://ctags.sourceforge.net/)

## Installation
Install the gem:

```bash
gem install rctags-watcher
```

Cloning the repo:

```bash
git clone https://github.com/vladbalmos/rctags-watcher
cd rctags-watcher
bundle install

# copy the default configuration file to your home directory and customize it
cp data/rctags-watcher.conf.dist ~/.rctags-watcher.conf

# start the program
bin/rctags-watcher.rb
```

## Configuration
By default **rctags-watcher** reads the following configuration files if they exist:

- /etc/rctags-watcher.conf
- ~/.rctags-watcher.conf

The last one can override configuration options specified in the global one.  
You can pass a different config file when starting **rctags-watcher** using the `-c` or `--config` flag

```bash
bin/rctags-watcher.rb --config /path/to/my/custom/config/file
```
This method won't load the main `/etc/rctags-watcher.conf` file or the one present in your $HOME directory. Each configuration change will require you to restart the **rctags-watcher** process.

To get started copy the default config file `data/rctags-watcher.conf` to `~/.rctags-watcher.conf` and create a new project section in it. See the [sample project](https://raw.githubusercontent.com/vladbalmos/rctags-watcher/master/data/rctags-watcher.conf.dist) for more information.

## Motivation
I wanted to learn Ruby and this seemed a great way to shoot two birds with one stone.

## Stable version
Danger! This is alpha quality software written by a Ruby begginer, as such, don't be surprised if your cat dies. What works for me, might not work for you. Use it at your own peril!
