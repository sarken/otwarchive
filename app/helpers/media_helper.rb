module MediaHelper
  def searchable_media_names
    media = Media.canonical.by_name - [Media.no_media] - [Media.uncategorized]
    media.map { |m| m.name }
  end
end
