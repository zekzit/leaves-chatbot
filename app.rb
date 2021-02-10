require 'dotenv/load'
require 'sinatra'
require 'yaml'

require 'line/bot'

black_list = ['U261a2a2e6ad61b184013fd78284bdd7a', 'U54ab4ed9c5c8d1884d762266713be048']

def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_id = ENV["LINE_CHANNEL_ID"]
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
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
          is_black_list = black_list.include? event["source"]["userId"]
          if is_black_list
            message["text"] = "#{message['text']} #ตอบตามมารยาท"
          end
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
