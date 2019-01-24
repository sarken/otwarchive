class MediaController < ApplicationController
  before_action :load_collection
  skip_before_action :store_location, only: [:show]

  def index
    uncategorized = Media.uncategorized
    @media = Media.by_name - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME), uncategorized] + [uncategorized]
    @fandom_listing = {}
    @media.each do |medium|
      if medium == uncategorized
        @fandom_listing[medium] = medium.children.in_use.by_type('Fandom').order('created_at DESC').limit(5)
      else
        @fandom_listing[medium] = (logged_in? || logged_in_as_admin?) ?
          # was losing the select trying to do this through the parents association
          Fandom.unhidden_top(5).joins(:common_taggings).where(canonical: true, common_taggings: {filterable_id: medium.id, filterable_type: 'Tag'}) :
          Fandom.public_top(5).joins(:common_taggings).where(canonical: true, common_taggings: {filterable_id: medium.id, filterable_type: 'Tag'})
      end
    end

    if params[:query].present? && params[:format] == "json"
      results = []
      found_fandoms = Tag.autocomplete_lookup(search_param: query_params[:name],
                                       autocomplete_prefix: "autocomplete_tag_fandom")
      found_fandoms.each do |fandom|
        fandom_name = Tag.name_from_autocomplete(fandom)
        tag = Tag.find_by(name: fandom_name)
        # In case our autocomplete data was stale and the tag no longer exists
        next if tag.nil?
        path_for_json = tag_works_path(tag)
        results << { name: fandom_name, url: path_for_json }
      end
    elsif params[:query].present?
      options = query_params.dup
      @query = options
      @tags = TagQuery.new(options).search_results
    end

    respond_to do |format|
      format.json { render :json => results.to_json }
      format.html
    end

    @page_subtitle = ts("Fandoms")
  end

  def show
    redirect_to medium_fandoms_path(medium_id: params[:id])
  end

  private

  def query_params
    params.require(:query).permit(
      :query, :type, :canonical, :name
    )
  end
end
