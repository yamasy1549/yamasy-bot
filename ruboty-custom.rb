require 'net/http'
require 'open-uri'
require 'json'
require 'rexml/document'

module Ruboty
  module Handlers

    RUBOTY_SORRY = "わかんない…"

    class Yojo < Base
      MESSAGES = %w(ようじょだよ！ ようじょちがう！ ふぇぇ〜〜)

      on(
        /.*ようじょ.*/,
        name: "yojo",
        description: "Return ようじょのおへんじ to ようじょ"
      )

      def yojo(message)
        message.reply(MESSAGES.sample)
      end
    end

    class Weather < Base
      on(
        /.*(今日|きょう)の(?<query>.+)の(天気|てんき).*/,
        name: "weather_today",
        description: "Return today's weather to 「今日の◯◯の天気」"
      )

      on(
        /.*(明日|あした)の(?<query>.+)の(天気|てんき).*/,
        name: "weather_tomorrow",
        description: "Return tomorrow's weather to 「明日の◯◯の天気」"
      )

      def weather_today(message)
        begin
          xml = "http://weather.livedoor.com/forecast/rss/primary_area.xml"
          doc = REXML::Document.new(open(xml))
          city_id = doc.elements["rss/channel/ldWeather:source/pref/city[@title='#{message[:query]}']"].attributes['id']
          uri = URI.parse("http://weather.livedoor.com/forecast/webservice/json/v1?city=#{city_id}")
          json = Net::HTTP.get(uri)
          result = JSON.parse(json)
          today = result["forecasts"][0]

          p today

          temperature = ""
          telop = today["telop"]

          unless today["temperature"]["max"].nil?
            temperature << "、最高気温は#{today['temperature']['max']['celsius']}℃"
          end

          unless today["temperature"]["min"].nil?
            temperature << "、最低気温は#{today['temperature']['min']['celsius']}℃"
          end

          weather_message = ""
          weather_message << "きょうの#{message[:query]}の天気は#{telop}" unless telop.nil?
          weather_message << temperature unless temperature
          weather_message << "だよ！"
          message.reply(weather_message)
        rescue
          message.reply(RUBOTY_SORRY)
        end
      end

      def weather_tomorrow(message)
        begin
          xml = "http://weather.livedoor.com/forecast/rss/primary_area.xml"
          doc = REXML::Document.new(open(xml))
          city_id = doc.elements["rss/channel/ldWeather:source/pref/city[@title='#{message[:query]}']"].attributes['id']
          uri = URI.parse("http://weather.livedoor.com/forecast/webservice/json/v1?city=#{city_id}")
          json = Net::HTTP.get(uri)
          result = JSON.parse(json)
          tomorrow = result["forecasts"][1]

          p tomorrow

          temperature = ""
          telop = tomorrow["telop"]

          unless tomorrow["temperature"]["max"].nil?
            temperature << "、最高気温は#{tomorrow['temperature']['max']['celsius']}℃"
          end

          unless tomorrow["temperature"]["min"].nil?
            temperature << "、最低気温は#{tomorrow['temperature']['min']['celsius']}℃"
          end

          weather_message = ""
          weather_message << "あしたの#{message[:query]}の天気は#{telop}" unless telop.nil?
          weather_message << temperature unless temperature
          weather_message << "だよ！"
          message.reply(weather_message)
        rescue
          message.reply(RUBOTY_SORRY)
        end
      end
    end

    class Sensor < Base
      SENSOR_PIN = 18

      on(
        /.*(誰|だれ)か.*/i,
        name: "human_sensor",
        description: "Return 人感センサに引っかかったか to 「誰か」"
      )

      def set_mode(pin, mode)
        begin
          io = open("/sys/class/gpio/export", "w")
          io.write(pin)
          io.close
          dir = open("/sys/class/gpio/gpio#{pin}/direction", "w")
          dir.write(mode)
          dir.close
        rescue
          `echo #{pin} > /sys/class/gpio/export`
          `echo #{mode} > /sys/class/gpio/gpio#{pin}/direction`
        end
      end

      def digital_read(pin)
        v = open("/sys/class/gpio/gpio#{pin}/value", "r")
        value = v.read
        v.close
        value
        # value = `cat /sys/class/gpio/gpio#{pin}/value`
      end

      def unexport(pin)
        io = open("/sys/class/gpio/unexport", "w")
        io.write(pin)
        io.close
        # `echo #{pin} > /sys/class/gpio/unexport`
      end

      def human_sensor(message)
        set_mode(SENSOR_PIN, "in")

        if digital_read(SENSOR_PIN).to_i == 1
          message.reply("いるよ！")
        else
          message.reply("いないよ…")
        end

        unexport(SENSOR_PIN)
      end
    end

    class Pux < Base
      REQUEST_URL = "http://" + ENV["PUX_REQUEST_DOMAIN"] + ":8080/webapi/face.do"
      AGENT = Mechanize.new

      on(
        /judge (?<query>.+)/,
        name: "judge",
        description: "Return judgement to 「judge <IMAGE_URL>」"
      )

      def judge(message)
        begin
          p "POST #{REQUEST_URL}"

          response = AGENT.post(REQUEST_URL, {
            apiKey: "#{ENV["PUX_API_KEY"]}",
            imageURL: message[:query],
            enjoyJudge: 1,
            response: "json"
          })

          p response

          if JSON.parse(response.body)["results"]["faceRecognition"]["errorInfo"].nil?
            message.reply(RUBOTY_SORRY)
          else
            results = JSON.parse(response.body)["results"]["faceRecognition"]["detectionFaceInfo"][0]

            age     = results["ageJudge"]["ageResult"] || RUBOTY_SORRY
            animal  = results["enjoyJudge"]["similarAnimal"] || RUBOTY_SORRY
            smile   = results["smileJudge"]["smileLevel"] || RUBOTY_SORRY
            doya    = results["enjoyJudge"]["doyaLevel"] || RUBOTY_SORRY
            trouble = results["enjoyJudge"]["troubleLevel"] || RUBOTY_SORRY

            if results["genderJudge"]["genderResult"].nil?
              gender = RUBOTY_SORRY
            elsif results["genderJudge"]["genderResult"] == 0
              gender = "おとこのこ"
            elsif results["genderJudge"]["genderResult"] == 1
              gender = "おんなのこ"
            end

            result_message = ""
            result_message << "\nねんれい: #{age}さい"
            result_message << "\nせいべつ: #{gender}"
            result_message << "\nどうぶつ: #{animal}"
            result_message << "\nえがお: #{smile}％"
            result_message << "\nどやがお: #{doya}％"
            result_message << "\nこまった: #{trouble}％"
          end

          message.reply(result_message)
        rescue
          message.reply(RUBOTY_SORRY)
        end
      end
    end
  end
end
