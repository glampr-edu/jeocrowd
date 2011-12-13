class SearchesController < ApplicationController

  def index
    @searches = Search.all
  end

  def show
    @search = Search.find(params[:id])
    return if @search.nil?
    if params[:restart_exploratory]
      @search.phase = "exploratory"
      @search.pages = []
      @search.xpTiles = {}
      @search.levels = []
      @search.rfTiles = []
      @search.statistics
      @search.save
    elsif params[:restart_refinement] && @search.phase != "exploratory"
      @search.phase = "exploratory"
      @search.levels = []
      @search.rfTiles = []
      @search.statistics
      @search.save
    end
    @search.current_client = @timestamp = (Time.now.to_f * 1000).to_i
    @search.save
  end

  def new
    @search = Search.new
  end

  def create
    @search = Search.find_by_keywords(params[:search] && params[:search][:keywords]) || Search.new(params[:search])
    if @search.save
      redirect_to @search
    else
      render action: "new"
    end
  end

  def update
    @search = Search.find(params[:id])
    @search.statistics[:total_available_points] = params[:total_available_points].to_i if params[:total_available_points]
    @new_timestamp = @search.updateExploratory(
                       params[:xpTiles], params[:page].to_i, params[:timestamp].to_i
                     ) if (params[:xpTiles] && params[:page])
    @new_block, @new_timestamp = @search.updateRefinement(
                                   params[:rfTiles], params[:level].to_i, params[:maxLevel].try(:to_i)
                                 ) if params[:rfTiles] && params[:level]
    @level = params[:level]
    @search.save
  end

  def destroy
    @search = Search.find(params[:id])
    @search.destroy
    redirect_to searches_url
  end
end
