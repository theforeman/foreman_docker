module ForemanDocker
  module ParameterValidators
    extend ActiveSupport::Concern
    include ::ParameterValidators

    def parameters_symbol
      return :environment_variables if is_a? Container
      super
    end
  end
end
