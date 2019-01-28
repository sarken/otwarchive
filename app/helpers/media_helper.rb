module MediaHelper
  def searchable_media_names
    media = Media.canonical.by_name - [Media.no_media] - [Media.uncategorized]
    media.map { |m| m.name }
  end

  def searchable_media
    media = Media.canonical.by_name - [Media.no_media] - [Media.uncategorized]
    media.map { |m| [m.name, m.id] }
  end
end
