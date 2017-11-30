require 'json'

class ApiResponse
  API_RESPONSES = YAML.load_file(
    "#{Rails.root.to_s}/config/api_responses.yml"
  ).with_indifferent_access

  RESPONSE_TYPES = [:carousel, :basic]

  class << self
    def replace_response(response, args)
      args.inject(response) do |replaced_response, (key, val)|
        replaced_response.gsub(/{#{key}}/, val.to_s)
      end
    end

    def get_response(namespace, args = {}, responses = API_RESPONSES)
      if namespace.class == Hash && responses.class == HashWithIndifferentAccess
        key = namespace.keys.first
        get_response(namespace[key], args, responses[key])
      else
        if responses.class == HashWithIndifferentAccess
          replace_response(random_response(responses[namespace]), args)
        else
          replace_response(random_response(responses), args)
        end
      end
    end

    def carousel_platform_responses(args)
      messages = []
      google_items = []

      args[:posts].each_with_index do |post, i|
        messages << fb_basic_card(post[:title], post[:image_url], post[:button_url])
        google_items << google_carousel_card_item(i, post[:title], post[:image_url], post[:button_url])
      end

      messages_hash_google = {
        :type => "carousel_card",
        :platform => "google",
        :items => google_items
      }

      messages + [messages_hash_google]
    end

    def basic_platform_responses(args)
      [
        fb_basic_card(args[:title], args[:image_url], args[:button_url]),
        google_basic_card(args)
      ]
    end

    def platform_responses(args, type = :basic)
      send("#{type}_platform_responses", args)
    end

    def google_basic_card(args)
      {
          "type": "basic_card",
          "platform": "google",
          "title": args[:title],
          "subtitle": args[:subtitle],
          "formattedText": args[:formatted_text],
          "image": {
            "url": args[:image_url]
          },
          "buttons": [
            {
              "title": args[:button_title],
              "openUrlAction": {
                "url": args[:button_url]
              }
            }
          ]
        }
    end

    def google_carousel_card_item(count, title, imageUrl, link)
      {
        :optionInfo => {
          :key => "Item #{count}",
          :synonyms => []
        },
        :title => title,
        :description => link,
        :imageUrl => {
          :url => imageUrl
        }
      }
    end

    def fb_basic_card(title, imageUrl, link)
      {
        :type => 1,
        :platform => "facebook",
        :title => title,
        :subtitle => "",
        :imageUrl => imageUrl,
        :buttons => [
          {
            :text => link,
            :postback => link
          }
        ]
      }
    end

    private

    def random_response(responses)
      responses.sample
    end
  end
end
