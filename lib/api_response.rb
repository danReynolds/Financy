require 'json'

class ApiResponse
  API_RESPONSES = YAML.load_file(
    "#{Rails.root.to_s}/config/api_responses.yml"
  ).with_indifferent_access

  RESPONSE_TYPES = [:carousel, :basic, :link_out]

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
        messages << basic_card('facebook', post[:title], post[:image_url], post[:button_url])
        messages << basic_card('slack', post[:title], post[:image_url], post[:button_url])
        google_items << google_carousel_card_item(post[:slug], post[:title], post[:image_url], post[:button_url])
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
        basic_card("facebook", args[:title], args[:image_url], args[:button_url]),
        basic_card("slack", args[:title], args[:image_url], args[:button_url]),
        google_basic_card(args)
      ]
    end

    def link_out_platform_responses(args)
      [
        google_link_out_card(args),
        basic_card("facebook", args[:title], args[:image_url], args[:url]),
        basic_card("slack", args[:title], args[:image_url], args[:url]),
      ]
    end

    def platform_responses(args, type = :basic)
      send("#{type}_platform_responses", args)
    end

    def google_link_out_card(args)
      {
          "type": "link_out_chip",
          "platform": "google",
          "destinationName": args[:title],
          "url": args[:url]
      }
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

    def google_carousel_card_item(slug, title, imageUrl, link)
      {
        :optionInfo => {
          :key => slug,
          :synonyms => []
        },
        :title => title,
        :description => link,
        :image => {
          :url => imageUrl,
          :accessibilityText => ""
        }
      }
    end

    def basic_card(platform, title, imageUrl, link)
      {
        :type => 1,
        :platform => platform,
        :title => title,
        :subtitle => "",
        :imageUrl => imageUrl,
        :buttons => [
          {
            :text => 'View',
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
