require_relative 'spec_helper'
require_relative '../lib/article'

describe Article do
  it 'has the item_id' do
    Article.new('item_id' => '58').id.must_equal '58'
  end

  describe '#word_count' do
    it 'has the word count when passed' do
      Article.new('word_count' => '123').word_count.must_equal 123
    end

    it 'defaults to 0 if not found in data' do
      Article.new({}).word_count.must_equal 0
    end
  end

  describe '#tags' do
    it 'has tags when passed' do
      data = {
        'tags' => {
          'foo' => { 'item_id' => '2', 'tag' => 'foo' },
          'bar' => { 'item_id' => '4', 'tag' => 'bar' }
        }
      }
      Article.new(data).tags.must_equal %w(foo bar)
    end

    it 'is empty when not passed' do
      Article.new({}).tags.must_equal []
    end
  end

  describe '#tag_name' do
    it 'returns a tag name depending on the time it should take to read' do
      data = { 'word_count' => '500' }
      Article.new(data, 250).tag_name.must_equal '2min'
    end

    [
      { word_count:  500, speed: 250, expected_tag:  '2min' },
      { word_count:  300, speed: 200, expected_tag:  '2min' },
      { word_count:  250, speed: 250, expected_tag:  '2min' },
      { word_count: 1000, speed: 500, expected_tag:  '2min' },
      { word_count: 1000, speed: 250, expected_tag:  '5min' },
      { word_count:  900, speed: 100, expected_tag: '10min' },
      { word_count: 1000, speed: 100, expected_tag: '10min' },
      { word_count: 1100, speed: 100, expected_tag: '20min' },
      { word_count: 1900, speed: 100, expected_tag: '20min' },
      { word_count: 2000, speed: 100, expected_tag: '20min' },
      { word_count: 3000, speed: 100, expected_tag: '30min' },
      { word_count: 3800, speed: 100, expected_tag: '40min' },
      { word_count: 4700, speed: 100, expected_tag: '50min' },
      { word_count: 6000, speed: 100, expected_tag: '60min' },
      { word_count: 8000, speed: 100, expected_tag: '90min' }
    ].each do |d|
      it "#{d[:word_count]} words should be in #{d[:expected_tag]} group
        when reading at #{d[:speed]} wpm" do

        data = { 'word_count' => d[:word_count] }
        Article.new(data, d[:speed]).tag_name.must_equal d[:expected_tag]
      end
    end

    it 'defaults to 250 words per minute' do
      Article.new('word_count' => '500').tag_name.must_equal '2min'
    end

    it 'doesnt tag the very short articles' do
      Article.new('word_count' => '5').tag_name.must_be_nil
    end

    it 'doesnt tag articles that will take longer than 90min' do
      Article.new('word_count' => '99999').tag_name.must_be_nil
    end
  end

  describe '#tag_needed?' do
    it 'is true if tag_name is present' do
      Article.new('word_count' => '600').must_be :tag_needed?
    end

    it 'returns false if tag_name is empty' do
      Article.new('word_count' => '0').wont_be :tag_needed?
    end

    it 'returns false if the same tag already exists' do
      tags = {
        '5min' => { 'item_id' => '5', 'tag' => '5min' },
        'code' => { 'item_id' => '2', 'tag' => 'code' }
      }
      a = Article.new({ 'word_count' => '1500', 'tags' => tags }, 300)
      a.wont_be :tag_needed?
    end
  end

  describe '#attrs_for_modification' do
    it 'has the item_id and tag that should be added' do
      a = Article.new('item_id' => '34', 'word_count' => '500')
      a.stubs(:tag_name).returns('foo')
      attrs = a.attrs_for_modification
      expected_attrs = {
        action:  :tags_add,
        item_id: '34',
        tags:    'foo'
      }
      attrs.must_equal expected_attrs
    end

    it 'is nil if no tag needed' do
      a = Article.new('word_count' => 1)
      a.attrs_for_modification.must_be_nil
    end
  end
end
