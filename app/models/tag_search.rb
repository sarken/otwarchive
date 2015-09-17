class TagSearch < Search
  
  def self.search(options={})
    query_string = self.new.escape_slashes(options[:name] || '')
    live_query_string = self.new.escape_slashes(options[:live_name] || '')
    response = Tag.tire.search(page: options[:page], per_page: 50, type: nil, load: false) do
      query do
        boolean do
          must { match :name, live_query_string, type: 'phrase_prefix' } if live_query_string.present?
          must { string query_string, default_operator: "AND" } if query_string.present?
          must { term '_type', options[:type].downcase } if options[:type].present?
          must { term :canonical, 'T' } if options[:canonical].present?
        end
      end
    end
    SearchResult.new('Tag', response)
  end
  
end