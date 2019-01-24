class FandomsController < ApplicationController
  before_action :load_collection

  def index
    medium = (params[:query].present? && params[:query][:medium]) ? params[:query][:medium] :
              params[:medium_id]
    @fandoms_list = Fandomslist.new(medium, @collection)

    if @collection
      @media = Media.canonical.by_name - [Media.find_by(name: ArchiveConfig.MEDIA_NO_TAG_NAME)] - [Media.find_by(name: ArchiveConfig.MEDIA_UNCATEGORIZED_NAME)]
      @page_subtitle = @collection.title
    elsif params[:medium_id]
      if @medium = Media.find_by_name(params[:medium_id])
         @page_subtitle = @medium.name
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find media category named '#{params[:medium_id]}'"
      end
    else
      redirect_to media_path(notice: "Please choose a media category to start browsing fandoms.")
      return
    end

    if params[:query].present? && params[:format] == "json"
      results = []
      if @collection || (medium.present? && Media.find_by_name(medium) == Media.uncategorized)
        found_fandoms = @fandoms_list.fandoms.where("name LIKE ?", '%' + params[:query][:name] + '%').limit(10)
        found_fandoms.each do |fandom|
          path_for_json = @collection ? collection_tag_works_path(@collection, fandom) : tag_path(fandom)
          results << { name: fandom.name, url: path_for_json }
        end
      else
        found_fandoms = Tag.autocomplete_media_lookup(term: params[:query][:name], tag_type: "fandom",
                                                      media: params[:query][:medium])
        found_fandoms.each do |fandom|
          fandom_name = Tag.name_from_autocomplete(fandom)
          path_for_json = tag_works_path(Tag.find_by_name(fandom_name))
          results << { name: fandom_name, url: path_for_json }
        end
      end
    end

    respond_to do |format|
      format.json { render :json => results.to_json }
      format.html
    end
  end

  def show
    @fandom = Fandom.find_by_name(params[:id])
    if @fandom.nil?
      flash[:error] = ts("Could not find fandom named %{fandom_name}", fandom_name: params[:id])
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
                      paginate(page: params[:page], per_page: 250)
  end
end
