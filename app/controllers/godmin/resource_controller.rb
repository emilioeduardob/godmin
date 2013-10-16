class Godmin::ResourceController < Godmin::ApplicationController
  inherit_resources
  load_and_authorize_resource

  before_action :prepend_resource_view_paths

  helper_method :attrs_for_index
  helper_method :attrs_for_form
  helper_method :filter_map

  def self.filter_map
    @filter_map ||= {}
  end

  def self.filters(attr, options = {})
    filter_map[attr] = { as: :string }.merge(options)
  end

  def attrs_for_index
    []
  end

  def attrs_for_form
    []
  end

  def filter_map
    self.class.filter_map
  end

  protected

  def collection
    @collection = end_of_association_chain.page params[:page]

    apply_filters params[:filter] if params[:filter]
    apply_order params[:order] if params[:order]

    @collection
  end

  def apply_filters(filters)
    filters.each do |name, value|
      if value.present? && filter_map.key?(name.to_sym)
        @collection = self.send("filter_#{name}", @collection, value)
      end
    end
  end

  def apply_order(order)
    order = order.split('_')
    direction = order.pop
    column = order.join('_')

    @collection = @collection.order("#{column} #{direction}")
  end


  private

  def prepend_resource_view_paths
     prepend_view_path "app/views/admin/resource"
     prepend_view_path "app/views/admin/#{resource_class.to_s.downcase.pluralize}"
  end
end
