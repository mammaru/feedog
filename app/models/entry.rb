# coding: utf-8
class Entry < ActiveRecord::Base
  belongs_to :feed
  has_one :clip, :dependent => :destroy

  MAX_NUMBER_OF_ENTRIES_PER_FEED = 50
  
  # kaminari
  #default_scope :order => 'RANDOM()'
  #default_scope :order => 'published_at DESC'
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
        Entry.destroy_all(:id => entries)
      end
    else
      Feed.all.each do |feed|
        entries = Entry.where(:feed_id => feed.id).pluck(:id)
        entries = entries - clipped_entries
        if entries.length > MAX_NUMBER_OF_ENTRIES_PER_FEED
          entries = entries.reverse[0..(MAX_NUMBER_OF_ENTRIES_PER_FEED-1)]
          entries.reverse!
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
    require 'natto'
    regex = /[一-龠]+|[ぁ-ん]+|[ァ-ヴー]+|[a-zA-Z0-9]+|[ａ-ｚＡ-Ｚ０-９]+/
    titles = ""
    texts = ""
    entries.each do |entry|
      titles += entry.title
      texts += entry.summary
    end
    texts += titles
    #p texts
    word_array = Array.new
    nm = Natto::MeCab.new
    #node = nm.parse(texts)
    #p node
    nm.parse(texts) do |node|
      #node = node.next
      if /^名詞/ =~ node.feature#.force_encoding("UTF-8")
        word_array << node.surface#.force_encoding("UTF-8")
      end
    end #until node.next.feature.include?("BOS/EOS")
    word_hash = Hash.new
    word_array.each do |key|
      word_hash[key] ||= 0
      word_hash[key] += 1
    end
    p word_hash.to_a
    return word_hash.to_a
    #results = nm.parse(texts)
    #nm.parse(texts) do |n|
      #puts "#{n.surface}\t#{n.feature}"
      #words.push(n.surface if n.)
    #end
    #puts results 
    #words = texts.scan regex
    #counts = Hash.new(0)
    #words.each{|word| counts[word] += 1}
    #sorted = counts.to_a.sort{|a,b| b[1] <=> a[1]}
    #sorted.each{|e| puts "#{e[0]}=>#{e[1]}"}
    #return results
  end

end
