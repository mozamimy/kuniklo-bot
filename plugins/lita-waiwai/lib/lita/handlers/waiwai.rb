require 'pp'

module Lita
  module Handlers
    class Waiwai < Handler
      REGISTRATION_API_ENDPOINT = "https://api.apigw.smt.docomo.ne.jp/naturalChatting/v1/registration?APIKEY=#{ENV.fetch('DOCOMO_API_KEY')}"
      DIALOGUE_API_ENDPOINT = "https://api.apigw.smt.docomo.ne.jp/naturalChatting/v1/dialogue?APIKEY=#{ENV.fetch('DOCOMO_API_KEY')}"

      route /おはなし$/, :initiate, command: true
      route /ばいばい$/, :finish, command: true
      route /.+/, :chat

      def initiate(response)
        unless redis.get("#{response.user.id}_app_id")
          app_id = set_app_id(response.user)
          if app_id
            response.reply("#{response.user.metadata['mention_name']} のこと覚えたよ")
          else
            response.reply("初期化に失敗したよ :cry:")
            return
          end
        end
        redis.set("#{response.user.id}_initiated", 'true')
      end

      def finish(response)
        redis.set("#{response.user.id}_initiated", 'false')
        response.reply('ばいばい')
      end

      def chat(response)
        state = redis.get("#{response.user.id}_initiated")
        app_id = redis.get("#{response.user.id}_app_id")

        if state == 'true' && app_id
          message = get_reply_message(app_id, response.message.body, response.user.metadata['mention_name'])
          response.reply(message)
        end
      end

      def set_app_id(user)
        uri = URI.parse(REGISTRATION_API_ENDPOINT)

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.open_timeout = 3
          http.read_timeout = 3
          request = Net::HTTP::Post.new(uri.request_uri, initheader = { 'Content-Type' => 'application/json' })
          request.body = {
            'botId' => 'Chatting',
            'appKind' => 'Smart Phone',
          }.to_json
          http.request(request)
        end

        case response
        when Net::HTTPSuccess
          app_id = JSON.parse(response.body)['appId']
          redis.set("#{user.id}_app_id", app_id)
          Lita.logger.info("Registerd #{user.metadata['mention_name']} (#{user.id}) with app_id #{app_id}.")
          app_id
        else
          Lita.logger.warn('Error on registration user')
          Lita.logger.warn("code: #{response.code}")
          Lita.logger.warn("body: #{response.body}")
          nil
        end
      end

      def get_reply_message(app_id, user_message, user_name)
        uri = URI.parse(DIALOGUE_API_ENDPOINT)

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.open_timeout = 3
          http.read_timeout = 3
          request = Net::HTTP::Post.new(uri.request_uri, initheader = { 'Content-Type' => 'application/json;charset=UTF-8' })
          request.body = {
            'language' => 'ja-JP',
            'botId' => 'Chatting',
            'appId' => app_id,
            'voiceText' => user_message,
            'clientData' => {
              'option' => {
                'nickname' => user_name,
                'mode' => 'dialog',
              },
            },
          }.to_json
          http.request(request)
        end

        case response
        when Net::HTTPSuccess
          bot_message = JSON.parse(response.body)['systemText']['expression']
          Lita.logger.info("Replied to #{user_name}: #{bot_message}")
          bot_message
        else
          Lita.logger.warn('Error on get reply message')
          Lita.logger.warn("code: #{response.code}")
          Lita.logger.warn("body: #{response.body}")
          nil
        end
      end

      Lita.register_handler(self)
    end
  end
end
