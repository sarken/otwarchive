class MediaController < ApplicationController
  before_filter :load_collection
  skip_before_filter :store_location, :only => [:show]

  def index
    uncategorized = Media.uncategorized
    @media = Media.by_name - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME), uncategorized] + [uncategorized]
    @fandom_listing = {}
    @media.each do |medium|
      if medium == uncategorized
        @fandom_listing[medium] = medium.children.in_use.by_type('Fandom').find(:all, :order => 'created_at DESC', :limit => 5)
      else
        @fandom_listing[medium] = (logged_in? || logged_in_as_admin?) ?
          # was losing the select trying to do this through the parents association
          Fandom.unhidden_top(5).find(:all, :joins => :common_taggings, :conditions => {:canonical => true, :common_taggings => {:filterable_id => medium.id, :filterable_type => 'Tag'}}) :
          Fandom.public_top(5).find(:all, :joins => :common_taggings, :conditions => {:canonical => true, :common_taggings => {:filterable_id => medium.id, :filterable_type => 'Tag'}})
      end
    end

    #if Rails.env.development?
      #@all_fandoms = Fandom.where(canonical: true)
    #else
      @all_fandoms = Rails.cache.fetch("all_fandoms", expires_in: 4.hours){ Fandom.where(canonical: true) }
    #end
    results = []
    @all_fandoms.each do |fandom|
      results << { name: fandom.name, url: tag_works_path(fandom) }
    end

    if params[:query].present?
      options = params[:query].dup
      @query = options
      @tags = TagSearch.search(options)
      if params[:format] == "json"
        results = []
        tags = Tag.autocomplete_lookup(search_param: params[:query][:name], autocomplete_prefix: "autocomplete_tag_fandom")
        tags.each do |fandom|
          fandom_name = Tag.name_from_autocomplete(fandom)
          results << { name: fandom_name, url: fandom_name.to_param }
        end
      end
    end

    respond_to do |format|
      format.json { render :json => results.to_json }
      format.html
    end

    @page_subtitle = ts("Fandoms")
  end

  def show
    redirect_to medium_fandoms_path(:medium_id => params[:id])
  end
end
