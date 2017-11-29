class WordpressController < ApplicationController
  include WordpressApi

  def categories
    categories = WordpressApi::get_categories(wordpress_params)
    if categories.length == 1
      category = categories.first
      posts = WordpressApi::get_posts_by_category(
        category_slug: category['slug'],
        post_size: wordpress_params[:post_size]
      )
      category_text = posts.map do |post|
        post['title']['rendered']
      end.en.conjunction(article: false)

      render json: {
        speech: "Got it. Here are some posts we found: #{category_text}."
      }
    else
      render json: {
        speech: categories.map { |category| category[:name] }.en.conjunction(article: false)
      }
    end
  end

  def category_slug
  end

  private

  def wordpress_params
    params.require(:result).require(:parameters).permit(
      :post_size, :post_category, :post_slug
    )
  end
end
