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
      default_items = []

      args[:posts].each_with_index do |post, i|
        messages << fb_basic_card(post[:title], post[:image_url], post[:button_url])
        google_items << google_carousel_card_item(i, post[:title], post[:image_url], post[:button_url])
        default_items << post[:link]
      end

      messages << default_google_message
      messages << default_facebook_message

      messages_hash_google = {
        :type => "carousel_card",
        :platform => "google",
        :items => google_items
      }

      message_hash_default = {
        :type => 0,
        :speech => "Hi, Here are some relevant articles that we found: #{default_items.join(", \n")}"
      }

      messages + [message_hash_default] + [messages_hash_google]
    end


    def link_out_platform_responses(args)
      [
        google_link_out_card(args),
        fb_basic_card(args[:title], args[:image_url], args[:url]),
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
        :type => 0,
        :platform => "facebook",
        :speech => "Hi, Here are some relevant articles that we found:"
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
        :image => {
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
