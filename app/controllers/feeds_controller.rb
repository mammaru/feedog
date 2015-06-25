class FeedsController < ApplicationController

  require 'feedjira'
  before_action :set_feed, :only => [:show, :edit, :update, :destroy, :fetch] 
  before_action :set_categories, :only => [:index, :show] 

  def feed_params
    params.require(:feed).permit(:category_id, :title, :url, :feed_url, :last_modified)
  end

  # GET /feeds
  # GET /feeds.json
  def index
    @entries = Entry.includes(:clip).all
    @feeds = Feed.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @feeds }
    end
  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show
    @entries = Entry.where(:feed_id => params[:id]).page(params[:page])
    respond_to do |format|
      format.html # show.html.erb
      format.json {
        render :json => {
                   :feed     => @feed,
                   :category => @category,
                   :entries  => @entries
               }
      }
    end
  end

  # GET /feeds/new
  # GET /feeds/new.json
  def new
    @feed = Feed.new
    @categories = Category.order(:name)
  end

  # GET /feeds/1/edit
  def edit
    @categories = Category.order(:name)
  end

  # POST /feeds
  # POST /feeds.json
  def create
    @feed = Feed.new(feed_params)
    respond_to do |format|
      if @feed.save
        format.html { redirect_to @feed, notice: 'Feed was successfully created.' }
        format.json { render json: @feed, status: :created, location: @feed }
      else
        format.html { render action: "new" }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /feeds/1
  # PUT /feeds/1.json
  def update
    #@feed = Feed.find(params[:id])
    respond_to do |format|
      if @feed.update(feed_params)
        format.html { redirect_to @feed, notice: 'Feed was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.json
  def destroy
    @feed.destroy
    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.json { head :no_content }
    end
  end

  def fetch_all

    Feed.all.each do |feed|

      if true #feed.entries.count == 0
        p 'Fetching feed from ' + feed.title
        parsedFeed = Feedjira::Feed.fetch_and_parse feed.feed_url
        flag = true
      else
        p 'Updating feed from ' + feed.title
        tmpfeed = Feedjira::Parser::RSS.new
        tmpfeed.feed_url = feed.url
        tmpfeed.title = feed.title
        tmpfeed.last_modified = feed.last_modified
        last_entry = Feedjira::Parser::RSSEntry.new
        last_e = feed.entries.order(:published_at => :desc).first
        last_entry.url = last_e.url
        tmpfeed.entries = [last_entry]
        parsedFeed = Feedjira::Feed.update tmpfeed
        parsedFeed.entries = parsedFeed.new_entries
        flag = parsedFeed.updated?
      end

      #p 'Updated entries exist? ' + flag.to_s
      
      if flag
        # Update feed meta data
        feed.title = parsedFeed.title
        feed.last_modified = parsedFeed.last_modified
        if parsedFeed.url then feed.url = parsedFeed.url end
        feed.save
        
        # Save entries
        parsedFeed.entries.reverse.each do |feed_entry|

          if !Entry.where(:url => feed_entry.url).exists?
          p 'Add => ' + feed_entry.url

          # destroy duplicate entry
          #Entry.destroy_all(:url => feed_entry.url)

          entry = Entry.new({
                                :title        => feed_entry.title,
                                :url          => feed_entry.url,
                                :summary      => (feed_entry.summary || feed_entry.content || '').gsub(/<.+?>/m, ''),#.slice(0, 255),
                                #:published_at => Time.parse(feed_entry.published.to_s),
                                :published_at => feed_entry.published.to_s,
                                :feed_id      => feed.id
                            })
          entry.save
          end
        end
      end
      
    end

    Entry.destroy_overflowed_entries
    
    @feeds = Feed.all
    redirect_to entries_path
  end

  def fetch

    #options = {
      #user_agent: USER_AGENT, 
      #if_modified_since: @feed.last_fetched, 
      #timeout: 30, 
      #max_redirects: 2,
      #compress: true
    #}

    if true #@feed.entries.count == 0
      p 'Fetching feed from ' + @feed.title.to_s
      parsedFeed = Feedjira::Feed.fetch_and_parse @feed.feed_url
      #new_entries = Feedjira::Feed.update_from_feed parsedFeed
      p parsedFeed.new_entries

      flag = true
    else
      p 'Updating feed from ' + @feed.title.to_s
      tmpfeed = Feedjira::Parser::RSS.new
      tmpfeed.feed_url = @feed.url
      tmpfeed.title = @feed.title
      tmpfeed.last_modified = @feed.last_modified
      last_entry = Feedjira::Parser::RSSEntry.new
      last_e = @feed.entries.order(:published_at => :desc).first
      last_entry.url = last_e.url
      #p last_entry.url
      tmpfeed.entries = [last_entry]
      parsedFeed = Feedjira::Feed.update tmpfeed
      parsedFeed.entries = parsedFeed.new_entries
      flag = parsedFeed.updated?
    end

    p 'Updated entries exist? ' + flag.to_s

    if flag
      # Update feed meta data
      @feed.title = parsedFeed.title
      @feed.last_modified = parsedFeed.last_modified
      if parsedFeed.url then @feed.url = parsedFeed.url end
      @feed.save

      # Save entries
      parsedFeed.entries.reverse.each do |feed_entry|

        # destroy duplicate entry
        #Entry.destroy_all(:url => feed_entry.url)

        if !Entry.where(:url => feed_entry.url).exists?
          p 'Add => ' + feed_entry.url
          entry = Entry.new({
                              :title        => feed_entry.title,
                              :url          => feed_entry.url,
                              :summary      => (feed_entry.summary || feed_entry.content || '').gsub(/<.+?>/m, ''),#.slice(0, 255),
                              #:published_at => Time.parse(feed_entry.published.to_s),
                              :published_at => feed_entry.published.to_s,
                              :feed_id      => @feed.id
                            })
          entry.save
        end
      end
    end
   
   if false #@feed.last_modified > 6.months.ago
      # destroy duplicate entry if not clipped
      entries_id = Entry.where("feed_id = ? AND published_at < ?", @feed.id, 6.months.ago).pluck(:id)
      clipped_entries_id = Clip.pluck(:entry_id)
      unclipped_entries_id = entries_id - clipped_entries_id
      Entry.where("id IN (?)", unclipped_entries_id).destroy_all()

   end

   Entry.destroy_overflowed_entries(@feed.id)
   
    #@feeds = Feed.all
    redirect_to feed_path
  end

 
  private

  def set_feed
    @feed = Feed.find(params[:id])
  end

  def set_categories
    @categories = Category.all
  end
  
end
