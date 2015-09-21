class FandomsController < ApplicationController
  before_filter :load_collection

  def index
    if @collection
      @media = Media.canonical.by_name - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME)]
      @page_subtitle = @collection.title

      # define the medium and fandoms if we are viewing or searching a specific media category
      if params[:medium_id] || (params[:query].present? && params[:query][:medium])
        @medium = Media.find_by_name(params[:medium_id] || params[:query][:medium])
        @fandoms = @medium.fandoms.canonical if @medium
      end
      @fandoms = (@fandoms || Fandom).where("filter_taggings.inherited = 0").by_name.
                  for_collections_with_count([@collection] + @collection.children)

      # live search results inside collections
      if params[:query].present? && params[:format] == "json"
        results = []
        tags = @fandoms.where("name LIKE ?", '%' + params[:query][:name] + '%').limit(10)
        tags.each do |fandom|
          results << { name: fandom.name, url: collection_tag_works_path(@collection, fandom) }
        end
      end

    elsif params[:medium_id]
      if @medium = Media.find_by_name(params[:medium_id])
         @page_subtitle = @medium.name
        if @medium == Media.uncategorized
          @fandoms = @medium.fandoms.in_use.by_name
        else
          @fandoms = @medium.fandoms.canonical.by_name.with_count
        end
        
        # live search results
        if params[:query].present? && params[:format] == "json"
          results = []
          # if this is the uncategorized media, query the database and use the tag_path
          if @medium == Media.uncategorized
            tags = @fandoms.where("name LIKE ?", '%' + params[:query][:name] + '%').limit(10)
            tags.each do |fandom|
              results << { name: fandom.name, url: tag_path(fandom) }
            end
          # for other media, we can take from the autocomplete and use the tag's works path
          else
            tags = Tag.autocomplete_media_lookup(term: params[:query][:name], tag_type: "fandom", media: params[:query][:medium])
            tags.each do |fandom|
              fandom_name = Tag.name_from_autocomplete(fandom)
              works_path = tag_works_path(Tag.find_by_name(fandom_name))
              results << { name: fandom_name, url: works_path }
            end
          end
        end
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find media category named '#{params[:medium_id]}'"
      end
    else
      redirect_to media_path(:notice => "Please choose a media category to start browsing fandoms.")
      return
    end
    @fandoms_by_letter = @fandoms.group_by {|f| f.sortable_name[0].upcase}

    respond_to do |format|
      format.json { render :json => results.to_json }
      format.html
    end

  end
  
  def show
    @fandom = Fandom.find_by_name(params[:id])
    if @fandom.nil?
      flash[:error] = ts("Could not find fandom named %{fandom_name}", :fandom_name => params[:id])
      redirect_to media_path and return
    end
    @characters = @fandom.characters.canonical.by_name
  end
  
  def unassigned
    join_string = "LEFT JOIN wrangling_assignments 
                  ON (wrangling_assignments.fandom_id = tags.id) 
                  LEFT JOIN users 
                  ON (users.id = wrangling_assignments.user_id)"
    conditions = "canonical = 1 AND users.id IS NULL"
    unless params[:media_id].blank?
      @media = Media.find_by_name(params[:media_id])
      if @media
        join_string <<  " INNER JOIN common_taggings 
                        ON (tags.id = common_taggings.common_tag_id)" 
        conditions  << " AND common_taggings.filterable_id = #{@media.id} 
                        AND common_taggings.filterable_type = 'Tag'"
      end
    end
    @fandoms = Fandom.joins(join_string).
                      where(conditions).
                      order(params[:sort] == 'count' ? "count DESC" : "sortable_name ASC").
                      with_count.
                      paginate(:page => params[:page], :per_page => 250)  
  end
end