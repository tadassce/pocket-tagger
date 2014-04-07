require_relative 'spec_helper'
require_relative '../lib/pocket_tagger'

describe PocketTagger do
  describe '#articles' do
    it 'returns a list of articles' do
      articles = nil
      VCR.use_cassette('retrieve') do
        token = '<Insert access token here>'
        articles = PocketTagger.new(token).articles
      end
      articles.first.word_count.must_equal 532
    end

    it 'calls the client with the token from initializer' do
      client = mock
      Pocket.expects(:client).with(access_token: 'foo').returns(client)
      client.expects(:retrieve).returns('list' => {})
      PocketTagger.new('foo').articles
    end

    it 'initializes the Article with the speed from initializer' do
      Article.expects(:new).with(anything, 300).at_least_once

      VCR.use_cassette('retrieve') do
        PocketTagger.new('foo', 300).articles
      end
    end
  end

  describe '#tag!' do
    before do
      @client = mock
      PocketTagger.any_instance.stubs(:client).returns(@client)
    end

    it 'sends the right arguments to modify' do
      pt = PocketTagger.new('token')
      articles = [
        Article.new('item_id' => '7', 'word_count' =>  '500'),
        Article.new('item_id' => '8', 'word_count' => '1000')
      ]
      pt.stubs(:articles).returns(articles)

      args = [
        { action: :tags_add, item_id: '7', tags: '2min' },
        { action: :tags_add, item_id: '8', tags: '5min' }
      ]
      @client.expects(:modify).with(args)

      pt.tag!
    end

    it 'doesnt tag if tag_name is empty' do
      pt = PocketTagger.new('token')
      articles = [Article.new('word_count' => '2')]
      pt.stubs(:articles).returns(articles)

      @client.expects(:modify).never

      pt.tag!
    end

    it 'returns the number of articles that were tagged' do
      pt = PocketTagger.new('token')
      articles = [
        Article.new('item_id' => '111', 'word_count' => '400'),
        Article.new('item_id' => '112', 'word_count' => '700'),
        Article.new('item_id' => '113', 'word_count' => '2')
      ]
      pt.stubs(:articles).returns(articles)
      pt.stubs(:client).returns(stub(:modify))
      pt.tag!.must_equal 2
    end
  end
end
