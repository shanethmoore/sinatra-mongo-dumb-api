require 'mongoid'
ENV['MONGOID_ENV'] ||= 'development'
# If Defined, great, otherwise it will be defined by Docker
ENV['MONGO_URL'] ||= 'mongo://127.0.0.1:27017'

Mongoid.logger.level = Logger::WARN
Mongo::Logger.logger.level = Logger::WARN

puts "Connecting to Mongo on: #{ENV['MONGO_URL']}"
Mongoid.load!('./config/mongoid.yml', ENV['MONGOID_ENV'])
