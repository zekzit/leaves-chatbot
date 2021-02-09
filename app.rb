require 'dotenv/load'
require 'sinatra'
require 'yaml'


get '/' do
    "Hello world! #{ENV['channel']} YO"
end

post '/' do
    payload = JSON.parse(request.body.read)

    logger.info "get data: -----------------------------------------"
    logger.info payload.to_yaml
    logger.info "---------------------------------------------------"
    "success"
end
