class EntriesController < ApplicationController

  before_action :set_clipped_entries, :only => :clipped

  def entry_params
    params.require(:entry).permit(:feed_id, :summary, :title, :url, :published_at)
  end

  # GET /entries
  # GET /entries.json
  def index
    @categories = Category.includes(:feeds).all
    # @feeds = Feed.all
    # @entries = Entry.includes(:clip).page(params[:page])
    @entries = Entry.includes(:clip).page(params[:page])
   respond_to do |format|
      format.html # index.html.erb
      format.json {
        render :json => {
                   :feed     => @feed,
                   :category => @category,
                   :entries  => @entries
               }
      }
    end
  end

  # GET /entries/1
  # GET /entries/1.json
  def show
    @entry = Entry.includes(:feed, :clip).find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json {
        render :json => {
                   :feed     => @feed,
                   :category => @category,
                   :entries  => @entry
               }
      }
    end
  end
  
  def search
    @feed = Feed.all
    @word = params[:search]
    @entries = Entry.search(@word).page(params[:page])
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

  def toggle_summary
    p params[:id]
    @entry = Entry.find(params[:id])
    #@e_id = params[:id]
  end
  
  private
  
  def set_clipped_entries
    clipped_entries_id = Clip.pluck(:entry_id)
    @entries = Entry.where(:id => clipped_entries_id).page(params[:page])    
  end

end
