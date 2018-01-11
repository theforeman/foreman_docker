class RemoveDockerSearchPermission < ActiveRecord::Migration[4.2]
  def up
    Permission.where(
      :name => "search_repository_image_search",
      :resource_type => 'Docker/ImageSearch').destroy_all
  end

  def down
    Permission.where(
      :name => "search_repository_image_search",
      :resource_type => 'DockerRegistry').destroy_all
  end
end
