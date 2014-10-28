class DockerRegistry < ActiveRecord::Base
  include Authorizable
  include Taxonomix

  has_many :docker_image_docker_registries
  has_many :images, :class_name => 'DockerImage',
           :through => :docker_image_docker_registries, :uniq => true

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :url

  def used_location_ids
    Location.joins(:taxable_taxonomies).where(
        'taxable_taxonomies.taxable_type' => 'DockerRegistry',
        'taxable_taxonomies.taxable_id' => id).pluck(:id)
  end

  def used_organization_ids
    Organization.joins(:taxable_taxonomies).where(
        'taxable_taxonomies.taxable_type' => 'DockerRegistry',
        'taxable_taxonomies.taxable_id' => id).pluck(:id)
  end
end
