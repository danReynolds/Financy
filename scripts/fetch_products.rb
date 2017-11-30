#!/usr/local/bin/ruby

require 'open-uri'
require 'pry'
require 'json'

base_url = 'https://www.nerdwallet.com/blog/wp-json/nw/v1/reviews/?per_page=100&_embed=true'

all_products = []

2.times do |i|
  url = "#{base_url}&page=#{i + 1}"
  products = JSON.parse(open(url).read)
  all_products += products.map do |product|
    name = product['title']['rendered_text']
    {
      value: name,
      synonyms: [
        name
      ]
    }
  end
end

File.write('products.txt', all_products.to_json)
