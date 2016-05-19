class DockerRegistry < ActiveRecord::Base
  include Authorizable
  include Taxonomix
  include Encryptable

  default_scope do
    with_taxonomy_scope do
      order('docker_registries.name')
    end
  end

  has_many :containers, :foreign_key => "registry_id", :dependent => :destroy
  encrypts :password

  attr_accessible :name, :url, :username, :password, :locations, :organizations,
    :description

  validates_lengths_from_database
  validates :name, :presence => true, :uniqueness => true
  validates :url,  :presence => true, :uniqueness => true,
    :url_schema => ['http', 'https']
  validate :attempt_login

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :url

  def used_location_ids
    Location.joins(:taxable_taxonomies).where(
      'taxable_taxonomies.taxable_type' => 'DockerRegistry',
      'taxable_taxonomies.taxable_id' => id).pluck("#{Taxonomy.table_name}.id")
  end

  def used_organization_ids
    Organization.joins(:taxable_taxonomies).where(
      'taxable_taxonomies.taxable_type' => 'DockerRegistry',
      'taxable_taxonomies.taxable_id' => id).pluck("#{Taxonomy.table_name}.id")
  end

  def prefixed_url(image_name)
    uri = URI(url)
    "#{uri.hostname}:#{uri.port}/#{image_name}"
  end

  def self.humanize_class_name(_name = nil)
    _("Docker/Registry")
  end

  private

  def attempt_login
    login_endpoint = RestClient::Resource.new(url + '/v1/users',
                                              :user => username,
                                              :password => password)
    login_endpoint.get == "\"OK\""
  rescue => e
    errors.add(:base, _('Unable to log in to this Docker Registry - %s') % e)
  end
end
