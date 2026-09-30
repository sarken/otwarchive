module StandaloneMetaHelper

  def metadata_label(text)
    text.html_safe + t("standalone_meta_helper.label_indicator")
  end

  # Spacing is dealt with in locale files, e.g. " : " for French.
  def tag_metadata(tags)
    return if tags.empty?

    "#{tag_metadata_label(tags)}#{tag_metadata_list(tags)}"
  end

  # We don't use .to_sentence because these aren't links and we risk making any
  # connector word (e.g., "and") look like part of the final tag.
  def tag_metadata_list(tags)
    return if tags.empty?

    tags.pluck(:name).join(t("support.array.words_connector"))
  end

  private

  def tag_metadata_label(tags)
    return if tags.empty?

    # i18n-tasks-use t('activerecord.models.archive_warning')
    # i18n-tasks-use t('activerecord.models.character')
    # i18n-tasks-use t('activerecord.models.fandom')
    # i18n-tasks-use t('activerecord.models.freeform')
    # i18n-tasks-use t('activerecord.models.rating')
    # i18n-tasks-use t('activerecord.models.relationship')
    type = tags.first.type
    t("activerecord.models.#{type.underscore}", count: tags.count) + t("standalone_meta_helper.label_indicator")
  end

end
