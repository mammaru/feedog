class ClipsController < ApplicationController

  def clip_params
    params.require(:clip).permit(:entry_id)
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
    
end
