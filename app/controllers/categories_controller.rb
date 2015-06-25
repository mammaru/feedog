# coding: utf-8
class CategoriesController < ApplicationController

  before_action :set_category, :only => [:show, :edit, :edit, :update, :destroy]
  before_action :set_categories, :only => [:index, :show, :edit, :new, :edit, :update]

  def category_params
    params.require(:category).permit(:name)
  end

  # GET /categories
  # GET /categories.json
  def index
    @entries = Entry.page(params[:page]) #発行順に並べ替えて取得
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @entries }
    end
  end

  def show_categories
    @entries = Entry.all
    @categories = Category.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    feed_id = Feed.where(:category_id => params[:id])
    @entries = Entry.where(:feed_id => feed_id).page(params[:page]) #発行順に並べ替えて取得
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @category }
    end
  end

  # GET /categories/new
  # GET /categories/new.json
  def new
    @category = Category.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @category }
    end
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)
    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'category was successfully created.' }
        format.json { render json: @category, status: :created, location: @category }
      else
        format.html { render action: "new" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PUT /categories/1
  # PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_path }
      format.json { head :no_content }
    end
  end

  private
  
  def set_category
    @category = Category.find(params[:id])
  end

  def set_categories
    @categories = Category.all
  end
  
end
