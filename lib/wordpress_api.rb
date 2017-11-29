module WordpressApi
  class WordpressApi < ExternalApi
    @api = load_api('wordpress_api')

    class << self
      def get_posts(args = {})
        url = replace_url(@api[:posts], args)
        fetch_response(url)
      end
    end
  end
end
