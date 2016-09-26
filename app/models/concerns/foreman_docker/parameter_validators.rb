module ForemanDocker
  module ParameterValidators
    extend ActiveSupport::Concern

    included do
      validate :validate_unique_parameter_keys
    end

    def validate_unique_parameter_keys
      parameters_symbol = [:environment_variables, :exposed_ports, :dns]
      parameters_symbol.each do |param_symbol|
        keys  = []
        errors = false

        self.public_send(param_symbol).each do |param|
          errors = duplicate_key?(keys, param)
        end

        self.errors[param_symbol] = _('Please ensure the following parameters are unique') if errors
      end
    end

    def duplicate_key?(keys, param)
      if keys.include?(param.key)
        param.errors[:key] = _('has already been taken')
        return true
      else
        keys << param.key
      end

      false
    end
  end
end
