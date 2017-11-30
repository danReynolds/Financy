require 'json'

class ApiResponse
  API_RESPONSES = YAML.load_file(
    "#{Rails.root.to_s}/config/api_responses.yml"
  ).with_indifferent_access

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



    def platform_responses(args)
      i = 0
      @messages = []
      @google_items = []
      args[:posts].each do |post|
        fb_carousel_card_item(post[:title], post[:imageUrl], post[:link])
        google_carousel_card_item(i+1, post[:title], post[:imageUrl], post[:link])
      end

      messages_hash_google = {
          :type => "carousel_card",
          :platform => "google",
          :items => @google_items
        }

      @messages << messages_hash_google
      # return {:messages => @messages}
      return @messages
    end

    def google_carousel_card_item(count, title, imageUrl, link)
      item = {
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
      @google_items << item
    end

    def fb_carousel_card_item(title, imageUrl, link)
      messages_hash_fb = {
          :type => 1,
          :platform => "facebook",
          :title => title,
          :subtitle => link,
          :imageUrl => imageUrl,
          :buttons => []
        }

      @messages << messages_hash_fb
    end

    private

    def random_response(responses)
      responses.sample
    end
  end
end
