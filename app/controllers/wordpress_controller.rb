class WordpressController < ApplicationController
  include WordpressApi

  def posts
    posts = WordpressApi::get_posts(wordpress_params)
  end

  private

  def wordpress_params
    params.require(:result).require(:parameters).permit(
      :post_size, :post_topic
    )
  end
end
