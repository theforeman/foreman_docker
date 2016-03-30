Deface::Override.new(
  :virtual_path => 'compute_resources/show',
  :name => 'rename_virtual_machines_containers',
  :replace => "erb[loud]:contains('Virtual Machines')",
  :text => "<%= if @compute_resource.type == 'ForemanDocker::Docker'
                  _('Containers')
                else
                  _('Virtual Machines')
                end %>"
)
