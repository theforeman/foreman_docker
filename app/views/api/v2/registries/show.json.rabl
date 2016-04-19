object @registry

extends "api/v2/registries/main"

node do |registry|
  partial("api/v2/taxonomies/children_nodes", :object => registry)
end
