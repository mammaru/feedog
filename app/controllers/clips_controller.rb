class ClipsController < ApplicationController

  before_action :set_clipped_entries, :except => [:create, :destroy]
  before_action :set_categories, :except => [:create, :destroy]
  
  def clip_params
    params.require(:clip).permit(:entry_id)
  end

  def index
  end

  def vis
    @results = Entry.word_count(@entries)
    gon.results = @results
  end

  # POST /clips
  # POST /clips.json
  def create
    @entry = Entry.find(params[:e_id])
    @entry.create_clip(:entry_id => params[:e_id]) unless Clip.where(:entry_id => params[:e_id]).exists?
  end

  # DELETE /clips/1
  # DELETE /clips/1.json
  def destroy
    @entry = Entry.find(params[:e_id])
    @clip = @entry.clip
    @clip.destroy
  end

  def set_clipped_entries
    clipped_entries_id = Clip.pluck(:entry_id)
    @entries = Entry.where(:id => clipped_entries_id).page(params[:page])    
  end

  def set_categories
    @categories = Category.all
  end

  
end
