class CollectionSearchForm

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  ATTRIBUTES = [
    :query,
    :title,
    :name,
    :created_at,
    :description,
    :parent_id,
    :collection_type,
    :signup_open,
    :moderated,
    :unrevealed,
    :anonymous,
    :closed,
    :moderated,
    :unrevealed,
    :anonymous,
    :signups_open_at,
    :signups_close_at,
    :assignments_due_at,
    :works_reveal_at,
    :authors_reveal_at,
    :sort_column,
    :sort_direction,
    :page
  ]

  attr_accessor :options

  ATTRIBUTES.each do |filterable|
    define_method(filterable) { options[filterable] }
  end

  def initialize(opts={})
    @options = opts
    process_options
    @searcher = CollectionQuery.new(@options)
  end

  def process_options
    @options.delete_if { |k, v| v == "0" || v.blank? }
    standardize_creator_queries
    standardize_language_ids
    set_sorting
    clean_up_angle_brackets
    rename_warning_field
  end

  # Make the creator/creators change backwards compatible
  def standardize_creator_queries
    return unless @options[:query].present?
    @options[:query] = @options[:query].gsub('creator:', 'creators:')
  end

  def standardize_language_ids
    # Maintain backward compatibility for old work searches/filters:

    # - Using language IDs in the "Language" dropdown
    if @options[:language_id].present? && @options[:language_id].to_i != 0
      language = Language.find_by(id: options[:language_id])
      options[:language_id] = language.short if language.present?
    end

    # - Using language IDs in "Any field" (search) or "Search within results" (filters)
    if @options[:query].present?
      @options[:query] = @options[:query].gsub(/\blanguage_id\s*:\s*(\d+)/) do
        lang = Language.find_by(id: Regexp.last_match[1])
        lang = Language.default if lang.blank?
        "language_id: " + lang.short
      end
    end
  end

  def set_sorting
    @options[:sort_column] ||= default_sort_column
    @options[:sort_direction] ||= default_sort_direction
  end

  def clean_up_angle_brackets
    [:word_count, :hits, :kudos_count, :comments_count, :bookmarks_count, :revised_at, :query].each do |countable|
      next unless @options[countable].present?
      str = @options[countable]
      @options[countable] = str.gsub("&gt;", ">").gsub("&lt;", "<")
    end
  end

  def rename_warning_field
    if @options[:warning_ids].present?
      @options[:archive_warning_ids] = @options.delete(:warning_ids)
    end
  end

  def persisted?
    false
  end

  def summary
    summary = []
    if @options[:query].present?
      summary << @options[:query].gsub('creators:', 'creator:')
    end
    if @options[:title].present?
      summary << "Title: #{@options[:title]}"
    end
    if @options[:creators].present?
      summary << "Author/Artist: #{@options[:creators]}"
    end
    tags = @searcher.included_tag_names
    all_tag_ids = @searcher.filter_ids
    unless all_tag_ids.empty?
      tags << Tag.where(id: all_tag_ids).pluck(:name).join(", ")
    end
    unless tags.empty?
      summary << "Tags: #{tags.uniq.join(", ")}"
    end
    if complete.to_s == "T"
      summary << "Complete"
    elsif complete.to_s == "F"
      summary << "Incomplete"
    end
    if crossover.to_s == "T"
      summary << "Only Crossovers"
    elsif crossover.to_s == "F"
      summary << "No Crossovers"
    end
    if %w(1 true).include?(self.single_chapter.to_s)
      summary << "Single Chapter"
    end
    if @options[:language_id].present?
      language = Language.find_by(short: @options[:language_id])
      if language.present?
        summary << "Language: #{language.name}"
      end
    end
    [:word_count, :hits, :kudos_count, :comments_count, :bookmarks_count, :revised_at].each do |countable|
      if @options[countable].present?
        summary << "#{countable.to_s.humanize.downcase}: #{@options[countable]}"
      end
    end
    if @options[:sort_column].present?
      summary << "sort by: #{name_for_sort_column(@options[:sort_column]).downcase}" +
        (@options[:sort_direction].present? ?
          (@options[:sort_direction] == "asc" ? " ascending" : " descending") : "")
    end
    summary.join(" ")
  end

  def search_results
    @searcher.search_results
  end

  ###############
  # SORTING
  ###############

  SORT_OPTIONS = [
    ['Best Match', '_score'],
    ['Author', 'authors_to_sort_on'],
    ['Title', 'title_to_sort_on'],
    ['Date Posted', 'created_at'],
    ['Date Updated', 'revised_at'],
    ['Word Count', 'word_count'],
    ['Hits', 'hits'],
    ['Kudos', 'kudos_count'],
    ['Comments', 'comments_count'],
    ['Bookmarks', 'bookmarks_count']
  ].freeze

  def sort_columns
    options[:sort_column] || default_sort_column
  end

  def sort_direction
    options[:sort_direction] || default_sort_direction
  end

  def sort_options
    options[:faceted] || options[:collected] ? SORT_OPTIONS[1..-1] : SORT_OPTIONS
  end

  def sort_values
    sort_options.map{ |option| option.last }
  end

  # extract the pretty name
  def name_for_sort_column(sort_column)
    Hash[SORT_OPTIONS.map { |v| [v[1], v[0]] }][sort_column]
  end

  def default_sort_column
    options[:faceted] || options[:collected] ? 'revised_at' : '_score'
  end

  def default_sort_direction
    if %w(authors_to_sort_on title_to_sort_on).include?(sort_column)
      'asc'
    else
      'desc'
    end
  end

  ###############
  # COUNTING
  ###############

  def self.count_for_user(user)
    Rails.cache.fetch(count_cache_key(user), count_cache_options) do
      WorkQuery.new(user_ids: [user.id]).count
    end
  end

  def self.count_for_pseud(pseud)
    Rails.cache.fetch(count_cache_key(pseud), count_cache_options) do
      WorkQuery.new(pseud_ids: [pseud.id]).count
    end
  end

  # If we want to invalidate cached work counts whenever the owner (which for
  # this method can only be a user or a pseud) has a new work, we can use
  # "#{owner.works_index_cache_key}" instead of "#{owner.class.name.underscore}_#{owner.id}".
  # See lib/works_owner.rb.
  def self.count_cache_key(owner)
    status = User.current_user ? 'logged_in' : 'logged_out'
    "work_count_#{owner.class.name.underscore}_#{owner.id}_#{status}"
  end

  def self.count_cache_options
    {
      expires_in: ArchiveConfig.SECONDS_UNTIL_DASHBOARD_COUNTS_EXPIRE.seconds,
      race_condition_ttl: 10.seconds
    }
  end
end