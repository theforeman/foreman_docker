Deface::Override.new(
  :virtual_path => 'compute_profiles/show',
  :name => 'remove_docker_from_compute_profiles',
  :replace => "erb[silent]:contains('ComputeResource.authorized(:view_compute_resources)')",
  :text => "<% ComputeResource.where.not(:type => 'ForemanDocker::Docker').
                 authorized(:view_compute_resources).each do |compute_resource| %>"
)

Deface::Override.new(
  :virtual_path => 'compute_resources/show',
  :name => 'remove_compute_profiles_tab',
  :replace => 'a[href="#compute_profiles"]',
  :text => "<%= link_to(_('Compute profiles'), '#compute_profiles', :'data-toggle' => 'tab') unless @compute_resource.type == 'ForemanDocker::Docker' %>"
)
