class WordpressController < ApplicationController
  include WordpressApi

  DEFAULT_CATEGORY_SIZE = 5

  def categories
    categories = WordpressApi::get_categories(wordpress_params)
    if categories.length == 1
      category = categories.first
      posts = WordpressApi::get_posts_by_category(
        category_slug: category['slug'],
        post_size: wordpress_params[:post_size]
      )

      args = {
        posts: posts.map do |post|
          {
            title: post['title']['rendered'],
            button_url: post['link'],
            image_url: post.dig('_embedded', 'wp:featuredmedia')[0]['source_url'],
            slug: post['slug']
          }
        end
      }

      render json: {
        speech: ApiResponse.get_response(:posts, args),
        messages: ApiResponse.platform_responses(args, :carousel),
        contextOut: [{
          name: 'posts', lifespan: 1, parameters: { posts: args[:posts] }
        }]
      }
    else
      args = {
        category: wordpress_params[:post_category],
        categories: categories.sample(DEFAULT_CATEGORY_SIZE)
          .map { |category| category['name'] }.en.conjunction(article: false)
      }
      render json: {
        speech: ApiResponse.get_response(:categories, args),
      }
    end
  end

  def product
    product = WordpressApi::get_product(wordpress_params.slice(:product)).first
    product_data = product.dig('nw_review_data', 'product_data', 'data')
    response_type = :basic
    args = if product_data
      {
        button_url: "https://nerdwallet.com#{product_data['detail_link']}",
        image_url: product_data['image_source_large'],
        button_title: 'View',
        formatted_text: '',
        title: product.dig('nw_review_data', 'name')
      }
    else
      response_type = :link_out
      { url: product['link'], title: product['title']['rendered'] }
    end

    render json: {
      speech: ApiResponse.get_response(:product, args),
      messages: ApiResponse.platform_responses(args, response_type)
    }
  end

  def tool
    tool = WordpressApi::get_tool(tool: wordpress_params[:tool])
    args = {
      title: tool['title']['rendered'],
      url: tool['nw_tool_url']
    }

    render json: {
      speech: ApiResponse.get_response(:tool, args),
      messages: ApiResponse.platform_responses(args, :link_out)
    }
  end

  def list_categories
    json = File.read('category_map.json')
    obj = JSON.parse(json)

    args = {
      category_list: obj.keys.sample(DEFAULT_CATEGORY_SIZE).join(', ')
    }
    render json: {
      speech: ApiResponse.get_response(:category_list, args)
    }
  end

  private

  def wordpress_params
    params.require(:result).require(:parameters).permit(
      :post_size, :post_category, :product, :tool
    )
  end
end
