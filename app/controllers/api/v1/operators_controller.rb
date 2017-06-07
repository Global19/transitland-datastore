class Api::V1::OperatorsController < Api::V1::EntityController
  AGGREGATE_CACHE_KEY = 'operators_aggregate_json'
  MODEL = Operator

  def aggregate
    # this cache will also be busted whenever an operator is saved
    aggregate_json = Rails.cache.fetch(AGGREGATE_CACHE_KEY, expires_in: 1.day) do
      json = {
        country: {},
        state: {},
        metro: {},
        timezone: {},
        name: {},
        short_name: {},
        tags: {}
      }
      json[:country] = count_values(Operator.pluck(:country), attr_name: :country)
      json[:state] = count_values(Operator.pluck(:state), attr_name: :state)
      json[:metro] = count_values(Operator.pluck(:metro), attr_name: :metro)
      json[:timezone] = count_values(Operator.pluck(:timezone), attr_name: :timezone)
      json[:name] = count_values(Operator.pluck(:name), attr_name: :name)
      json[:short_name] = count_values(Operator.pluck(:short_name), attr_name: :short_name)
      json[:tags] = count_and_gather_values(Operator.pluck(:tags))
      json
    end
    render json: aggregate_json
  end

  private

  def index_query
    super
    # Operators
    @collection = AllowFiltering.by_attribute_array(@collection, params, :country)
    @collection = AllowFiltering.by_attribute_array(@collection, params, :state)
    @collection = AllowFiltering.by_attribute_array(@collection, params, :metro)
    @collection = AllowFiltering.by_attribute_array(@collection, params, :timezone)
    @collection = AllowFiltering.by_attribute_array(@collection, params, :name)
    @collection = AllowFiltering.by_attribute_array(@collection, params, :short_name)
  end

  def query_params
    params.slice(
      :lat,
      :lon,
      :r,
      :bbox,
      :onestop_id,
      :tag_key,
      :tag_value,
      :import_level,
      :name,
      :short_name,
      :imported_from_feed,
      :imported_from_feed_version,
      :imported_from_active_feed_version,
      :imported_with_gtfs_id,
      :gtfs_id,
      :country,
      :state,
      :metro,
      :timezone,
      :updated_since
    )
  end

  def count_values(array_of_hashes, attr_name: nil)
    return_hash = {}
    counts_hash = array_of_hashes.reduce(Hash.new(0)) do |counts, key|
      counts[key] += 1
      counts
    end
    counts_hash.sort_by { |key, value| -value }.to_h # descending order
    counts_hash.each do |key, value|
      return_hash[key] ||= {}
      return_hash[key][:count] = value
      if attr_name.present?
        return_hash[key][:query_url] = api_v1_operators_url("#{attr_name}".to_sym => key)
      end
    end
    return_hash
  end

  def count_and_gather_values(array_of_hashes)
    return_hash = {}
    keys = array_of_hashes.map(&:keys).flatten
    values_by_key = group_values_by_key(array_of_hashes)
    counts_by_key = count_values(keys)
    keys.uniq.each do |key|
      return_hash[key] = {
        count: counts_by_key[key][:count],
        values: values_by_key[key],
        query_url: api_v1_operators_url(tag_key: key)
      }
    end
    return_hash
  end

  def group_values_by_key(array_of_hashes)
    counts_hash = array_of_hashes.reduce(Hash.new {|h,k| h[k]=Set.new}) do |aggregate_hash, incoming_hash|
      incoming_hash.each do |key, value|
        aggregate_hash[key] << value
      end
      aggregate_hash
    end
    counts_hash.sort_by { |key, value| -value.count }.to_h # descending order
  end
end
