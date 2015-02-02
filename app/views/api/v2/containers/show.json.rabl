object @container

extends "api/v2/containers/main"

node do |container|
  partial("api/v2/taxonomies/children_nodes", :object => container)
end
