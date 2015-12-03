# This file is used by Rack-based servers to start the application.
require 'sinatra'

ENV_TEST ||= ENV['RACK_ENV'].eql?('test')
ENV_DEVELOPMENT ||= ENV['RACK_ENV'].eql?('development')
ENV_PRODUCTION ||= ENV['RACK_ENV'].eql?('production')

require './app'
run Rack::URLMap.new('/' => UITestConversationsApiApp)
