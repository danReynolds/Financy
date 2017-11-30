require 'json'

class ApiResponse
  API_RESPONSES = YAML.load_file(
    "#{Rails.root.to_s}/config/api_responses.yml"
  ).with_indifferent_access

  class << self

    @google_items = []
    @messages = []

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



    def platform_responses(args)

      args['posts'].each_value do |value|

      end

      messages_hash_google = {
          :type => "carousel_card",
          :platform => "google",
          :items => google_items
        }

      messages.push(messages_hash_google)

      return {:messages => messages}
    end

    def google_carousel_card_item(args count, title, imageUrl, link)
      item = {
        :optionInfo => {
          :key => "Item #{count}",
          :synonyms => []
        },
        :title => args[posts],
        :description => link,
        :imageUrl => {
          :url => imageUrl
        }
      }
      google_items.push(item)
    end

    def fb_carousel_card_item(title, imageUrl, link)
      messages_hash_fb = {
          :type => 1,
          :platform => "facebook",
          :title => tile,
          :subtitle => link,
          :imageUrl => imageUrl,
          :buttons => []
        }

      messages.push(messages_hash_fb)
    end

    private

    def random_response(responses)
      responses.sample
    end
  end
end
