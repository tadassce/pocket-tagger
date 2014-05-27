class Article
  attr_accessor :speed, :data

  def initialize(data, speed = nil)
    @data  = data
    @speed = speed || 150
  end

  def id
    data.fetch('item_id')
  end

  def word_count
    data.fetch('word_count', 0).to_i
  end

  def tags
    data['tags'] ? data['tags'].keys : []
  end

  def attrs_for_modification
    return unless tag_needed?
    {
      action:  :tags_add,
      item_id: id,
      tags:    tag_name
    }
  end

  def tag_name
    "#{minutes_group}min" if minutes_group
  end

  private

  def tag_needed?
    return false unless tag_name
    !tags.include? tag_name
  end

  def minutes_to_read
    word_count / speed.to_i
  end

  def minutes_group
    case minutes_to_read
    when  1..2  then 2
    when  3..5  then 5
    when  6..10 then 10
    when 11..20 then 20
    when 21..30 then 30
    when 31..40 then 40
    when 41..50 then 50
    when 51..60 then 60
    when 61..90 then 90
    end
  end
end
