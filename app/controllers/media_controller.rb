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

    if params[:query].present? && params[:format] == "json"
      results = []
      fandoms = Tag.autocomplete_lookup(search_param: params[:query][:name],
                                    autocomplete_prefix: "autocomplete_tag_fandom")
      fandoms.each do |fandom|
        fandom_name = Tag.name_from_autocomplete(fandom)
        results << { name: fandom_name, url: fandom_name.to_param }
      end
    elsif params[:query].present?
      options = params[:query].dup
      @query = options
      @tags = TagSearch.search(options)
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
