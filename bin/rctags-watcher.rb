#!/usr/bin/env ruby

require_relative "../lib/rctags-watcher"
require "etc"

CONFIG_FILENAME = 'rctags-watcher.conf'

local_config_file = File.expand_path('~') + '/.' + CONFIG_FILENAME
global_config_file = Etc.sysconfdir + '/' + CONFIG_FILENAME
config_files = []
if File.file? global_config_file
    config_files << global_config_file
end

if File.file? local_config_file
    config_files << local_config_file
end

app = RctagsWatcher.new
app.start
