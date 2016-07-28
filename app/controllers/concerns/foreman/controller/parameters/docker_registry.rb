module Foreman::Controller::Parameters::DockerRegistry
  extend ActiveSupport::Concern

  class_methods do
    def docker_registry_params_filter
      Foreman::ParameterFilter.new(::DockerRegistry).tap do |filter|
        filter.permit :name, :url, :username, :password, :description,
                      :location_ids => [], :organization_ids => []
      end
    end
  end

  def docker_registry_params
    param_name = parameter_filter_context.api? ? 'registry' : 'docker_registry'
    self.class.docker_registry_params_filter.filter_params(params, parameter_filter_context,
                                                           param_name
                                                          )
  end
end
