class DockerParameter < ActiveRecord::Base
  extend FriendlyId
  friendly_id :key
  include Parameterizable::ByIdName

  validates_lengths_from_database

  include Authorizable
  validates :key, :presence => true, :no_whitespace => true

  scoped_search :on => :key, :complete_value => true

  default_scope -> { order("docker_parameters.key") }

  before_validation :strip_whitespaces

  def strip_whitespaces
    self.value.strip! unless value.blank?
  end
end
