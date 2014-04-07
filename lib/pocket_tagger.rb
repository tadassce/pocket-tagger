require 'pocket'
require_relative 'article'
require_relative '../config/pocket'

class PocketTagger
  attr_accessor :speed, :data

  def initialize(access_token, speed = nil)
    @token = access_token
    @speed = speed
  end

  def articles
    fetch_data
    @data.fetch('list').values.map { |data| Article.new(data, @speed) }
  end

  def tag!
    client.modify(articles_to_modify) unless articles_to_modify.empty?
    articles_to_modify.count
  end

  private

  def articles_to_modify
    @atm ||= articles.map(&:attrs_for_modification).compact
  end

  def fetch_data
    @data ||= client.retrieve(detailType: :complete)
  end

  def client
    Pocket.client(access_token: @token)
  end
end
