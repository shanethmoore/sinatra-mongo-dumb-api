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
require_relative 'app/models/conversation'
require_relative 'config/initializers/mongoid'

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

  helpers do
    def serialize_data(obj)
      JSON.dump(obj)
    end
  end

  get '/conversations' do
    conversations = Conversation.all.map do |conversation|
      hash = Hash[conversation.attributes]
      hash['_id'] = hash['_id'].to_s
      hash
    end
    if conversations.count > 0
      status 200
      body serialize_data(conversations)
    else
      status 404
      body serialize_data("no conversations saved")
    end
  end

  post '/conversations/new' do
    conversation = Conversation.new
    conversation_data = (JSON.parse request.body.read)
    conversation.data = conversation_data
    if conversation.save
      status 201
    else
      status 400
      body serialize_data("could not save conversation #{conversation.errors}")
    end
  end

  put '/conversations/:id' do
    conversation = Conversation.by_id(params[:id]).first
    conversation_data = (JSON.parse request.body.read)
    if conversation.nil?
      status 404
      body serialize_data("No conversation found for it #{params[:id]}")
      return
    else
      conversation.data = conversation_data
      if conversation.save
        status 200
      else
        status 400
        body serialize_data("could not save conversation #{conversation.errors}")
      end
    end
  end

  delete '/conversations/:id' do
    conversation = Conversation.by_id(params[:id]).first
    if conversation.nil?
      status 404
      return serialize_data("No conversation found for it #{params[:id]}")
    else
      conversation.destroy
    end
  end

  delete '/conversations/delete_all' do
    count = Conversation.count
    Conversation.destroy_all
    status 200
    body "OK: #{count}"
  end

  get '/conversations/delete_all' do
    count = Conversation.count
    Conversation.destroy_all
    status 200
    body "OK: #{count}"
  end
end
