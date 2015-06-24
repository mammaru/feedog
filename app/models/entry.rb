# coding: utf-8
class Entry < ActiveRecord::Base
  belongs_to :feed
  has_one :clip, :dependent => :destroy

  MAX_NUMBER_OF_ENTRIES_PER_FEED = 50
  require 'natto'
  
  # kaminari
  default_scope { order(published_at: :desc) }
  #default_scope { order('RANDOM()') }
  #paginates_per 50
  
  def self.destroy_overflowed_entries(*feed_id)
    clipped_entries = Clip.pluck(:entry_id)
    if feed_id
      entries = Entry.where(:feed_id => feed_id).pluck(:id)
      entries = entries - clipped_entries
      if entries.length > MAX_NUMBER_OF_ENTRIES_PER_FEED
        entries = entries.reverse[0..(MAX_NUMBER_OF_ENTRIES_PER_FEED-1)]
        entries.reverse!
        p "Destroy entries from a feed"
        Entry.destroy_all(:id => entries)
      end
    else
      Feed.all.each do |feed|
        entries = Entry.where(:feed_id => feed.id).pluck(:id)
        entries = entries - clipped_entries
        if entries.length > MAX_NUMBER_OF_ENTRIES_PER_FEED
          entries = entries.reverse[0..(MAX_NUMBER_OF_ENTRIES_PER_FEED-1)]
          entries.reverse!
          p "Destroy entries from feed #{feed.title}"
          Entry.destroy_all(:id => entries)
        end
      end
    end
  end

  #クラスメソッドseach
  def self.search(search)
    if search
      Entry.where(['title LIKE ? or summary LIKE ?', "%#{search}%", "%#{search}%"])
    else
      Entry.all
    end
  end
  
  def self.word_count(entries)

    #regex = /[一-龠]+|[ぁ-ん]+|[ァ-ヴー]+|[a-zA-Z0-9]+|[ａ-ｚＡ-Ｚ０-９]+/
    titles = ""
    texts = ""
    entries.each do |entry|
      titles += entry.title
      texts += entry.summary
    end
    texts += titles # とりあえず

    word_array = Array.new
    nm = Natto::MeCab.new
    nm.parse(texts) do |node| # 名詞だけword_arrayへ
      if /^名詞/ =~ node.feature#.force_encoding("UTF-8")
        word_array << node.surface#.force_encoding("UTF-8")
      end
    end
    word_hash = Hash.new
    word_array.each do |key|
      word_hash[key] ||= 0
      word_hash[key] += 1
    end

    word_hash = word_hash.sort_by {|k, v| v}.to_h # sort by word count
    
    words_total = word_hash.values.inject(0){|sum, i| sum+i}
    p words_total
    word_hash_normalized = word_hash.map {|k, v| [k, v.quo(words_total).to_f]}.to_h
    p word_hash
    p word_hash_normalized
    #return word_hash.to_a
    return word_hash_normalized.to_a

    #nm.parse(texts) do |n|
      #puts "#{n.surface}\t#{n.feature}"
      #words.push(n.surface if n.)
    #end
  end

end
