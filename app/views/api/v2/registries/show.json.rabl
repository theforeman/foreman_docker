object @registry

extends "api/v2/registries/main"

node do |container|
  partial("api/v2/taxonomies/children_nodes", :object => container)
end
