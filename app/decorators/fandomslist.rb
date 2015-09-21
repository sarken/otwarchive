class Fandomslist
  def initialize(media = nil, collection = nil)
    @media = media
    @collection = collection
  end

  def medium
    return unless @media
    @medium = Media.find_by_name(@media)
  end

  def fandoms
    if @collection
      @fandoms = medium.fandoms.canonical if medium
      @fandoms = (@fandoms || Fandom).where("filter_taggings.inherited = 0").by_name.
                                      for_collections_with_count([@collection] + @collection.children)
    elsif medium == Media.uncategorized
      @fandoms = medium.fandoms.in_use.by_name
    else
      @fandoms = medium.fandoms.canonical.by_name.with_count
    end 
  end

  def fandoms_by_letter
    fandoms.group_by {|f| f.sortable_name[0].upcase}
  end
end
