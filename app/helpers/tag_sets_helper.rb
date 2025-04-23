# These methods return information about the given TagSetNomination or the
# tags in a a TagSet
module TagSetsHelper

  def nomination_notes(limit)
    message = ""
    if limit[:fandom] > 0
      if limit[:character] > 0
        if limit[:relationship] > 0
          message = t("tag_sets_helper.nomination_notes.fandoms.characters_and_relationships", fandom_limit: t("tag_sets_helper.nomination_notes.fandom_limit", count: limit[:fandom]), character_limit: t("tag_sets_helper.nomination_notes.character_limit", count: limit[:character]), relationship_limit: t("tag_sets_helper.nomination_notes.relationship_limit", count: limit[:relationship]))
        else
          message = t("tag_sets_helper.nomination_notes.fandoms.characters", fandom_limit: t("tag_sets_helper.nomination_notes.fandom_limit", count: limit[:fandom]), character_limit: t("tag_sets_helper.nomination_notes.character_limit", count: limit[:character]))
        end
      elsif limit[:relationship] > 0
        message = t("tag_sets_helper.nomination_notes.fandoms.relationships", fandom_limit: t("tag_sets_helper.nomination_notes.fandom_limit", count: limit[:fandom]), relationship_limit: t("tag_sets_helper.nomination_notes.relationship_limit", count: limit[:relationship]))
      else
        message = t("tag_sets_helper.nomination_notes.fandoms.only", fandom_limit: t("tag_sets_helper.nomination_notes.fandom_limit"))
      end
    else
      if limit[:character] > 0
        if limit[:relationship] > 0
          message = t("tag_sets_helper.nomination_notes.characters.relationships", character_limit: t("tag_sets_helper.nomination_notes.character_limit", count: limit[:character]), relationship_limit: t("tag_sets_helper.nomination_notes.relationship_limit", count: limit[:relationship]))
        else
          message = t("tag_sets_helper.nomination_notes.characters.only", character_limit: t("tag_sets_helper.nomination_notes.character_limit", count: limit[:character]))
        end
      elsif limit[:relationship] > 0
        message = t("tag_sets_helper.nomination_notes.relationships_only", relationship_limit: t("tag_sets_helper.nomination_notes.relationship_limit", count: limit[:relationship]))
      end
    end

    if limit[:freeform] > 0
      if message.blank?
        message = t("tag_sets_helper.nomination_notes.additional_tags.only", additional_tag_limit: t("tag_sets_helper.nomination_notes.additional_tag_limit", count: limit[:freeform]))
      else
        message += t("tag_sets_helper.nomination_notes.additional_tags.and", additional_tag_limit: t("tag_sets_helper.nomination_notes.additional_tag_limit", count: limit[:freeform]))
      end
    end

    message
  end

  def nomination_status(nomination = nil)
    symbol = "?!"
    status = "unreviewed"
    tooltip = t("tag_sets_helper.nomination_status.unreviewed")
    if nomination
      if nomination.approved
        symbol = "&#10004;"
        status = "approved"
        tooltip = t("tag_sets_helper.nomination_status.approved")
      elsif nomination.rejected
        symbol = "&#10006;"
        status = "rejected"
        tooltip = t("tag_sets_helper.nomination_status.rejected")
      elsif @tag_set.nominated
        symbol = "?!"
        status = "unreviewed"
        tooltip = t("tag_sets_helper.nomination_status.unreviewed_editable")
      end
    end

    return content_tag(:span, content_tag(:span, "#{symbol}".html_safe), class: "#{status} symbol", data: { tooltip: tooltip })
  end

  def nomination_tag_information(nominated_tag)
    tag_object = Tag.find_by(name: nominated_tag.tagname)
    status = "nonexistent"
    tooltip = ts("This tag has never been used before. Check the spelling!")
    title = ts("nonexistent tag")
    span_content = nominated_tag.tagname
    synonym_for = ""
    case
    when nominated_tag.canonical
      if nominated_tag.parented
        status = "canonical"
        tooltip = ts("This is a canonical tag.")
        title = ts("canonical tag")
        span_content = link_to_tag_works(tag_object)
      else
        status = "unparented"
        tooltip = ts("This is a canonical tag but not associated with the specified fandom.")
        title = ts("canonical tag without parent")
        span_content = link_to_tag_works(tag_object)
      end
    when nominated_tag.synonym
      status = "synonym"
      tooltip = ts("This is a synonym of a canonical tag.")
      title = ts("tag synonym")
      synonym_for = content_tag(:span, " (#{link_to_tag_works(tag_object.merger, class: "canonical")})".html_safe)
    when nominated_tag.exists
      status = "unwrangled"
      tooltip = ts("This is not a canonical tag.")
      title = ts("non-canonical tag")
    end

    return content_tag(:span, "#{span_content}".html_safe, class: "#{status} nomination", title: "#{title}", data: {tooltip: "#{tooltip}"}) + synonym_for

  end

  def tag_relation_to_list(tag_relation)
    tag_relation.by_name_without_articles.pluck(:name).map {|tagname| content_tag(:li, tagname)}.join("\n").html_safe
  end

end
