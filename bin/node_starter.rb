$LOAD_PATH << 'lib'
require 'bundler/setup'
require 'node_starter'

NodeStarter.setup

NodeStarter::QueueSubscribe.new.start_listening
