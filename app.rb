# encoding: UTF-8
Encoding.default_external = Encoding::UTF_8 # Stops JSON errors
VERSION = 1.0
puts "Loading Conversations API Version #{VERSION}"

require 'net/https'
require 'sinatra'
require 'sinatra/base'
require 'rake'
require 'json'
require 'mongoid'
require 'rack/cache'
require_relative 'config/initializers/mongois'


class UITestConversationsApiApp < Sinatra::Base

  set :environment, ENV['RACK_ENV'].to_s.to_sym

  configure do
    enable :logging

    use Rack::Cache,
        metastore: 'file:/tmp/meta',
        entitystore: 'file:/tmp/body'
  end

  before do
    content_type 'application/json'
  end

  not_found do
    status 404
    body serialize_data(error: 'Not Found')
  end

  error do
    status 500
    return serialize_data(error: error_message)
  end

  helpers do
    def serialize_data(obj)
      JSON.dump(obj)
    end
  end

  get '/conversations' do
    cache_control :public, max_age: 10 # 30 seconds
    conversations = Conversation.all.map do |conversation|
      JSON.dump(conversation)
    end
    if conversations.count > 0
      status 200
      body serialize_data(conversations)
    else
      status 404
      body serialize_data("no conversations saved")
    end
  end

  put '/conversation/:id/:conversation_data' do
    conversation = Conversation.by_id(params[:id]).first
    if conversation.nil?  status 404
      body serialize_data("No conversation found for it #{params[:id]}")
      return
    else
      conversation.data = params[:conversation_data]
      if conversation.save
        status 200
      else
        status 500
        body serialize_data("could not save conversation #{conversation.errors}")
      end
    end
  end

  post '/conversation/:conversation_data' do
    conversation = Conversation.new

    if conversation.save
      status 201
    end
    body serialize_data("No conversation found for it #{params[:id]}")
  end

  delete '/conversation/:id' do
    conv = Conversation.by_id(params[:id]).first
    if conv.nil?
      status 404
      return serialize_data("No conversation found for it #{params[:id]}")
    end
  end
end
