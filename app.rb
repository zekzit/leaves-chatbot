require 'dotenv/load'
require 'sinatra'
require 'yaml'

require 'line/bot'

def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_id = ENV["channel"]
      config.channel_secret = ENV["secret"]
    #   config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
end


get '/' do
    "Hello world! #{ENV['channel']} YO"
end

post '/' do
    body = request.body.read

    # signature = request.env['x-line-signature']
    # logger.info "signature = #{signature}"
    # unless client.validate_signature(body, signature)
    #     error 400 do 'Bad Request' end
    # end

    events = client.parse_events_from(body)

    logger.info "get data: -----------------------------------------"
    logger.info body.to_yaml
    logger.info "---------------------------------------------------"

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end
    end

    "OK"
end
