module ForemanDocker
  module ContainerRemover
    module_function

    def remove_unmanaged(compute_resource_id, uuid)
      deleted_identifier = uuid

      ComputeResource.
        authorized(:destroy_compute_resources_vms).
        find(compute_resource_id).
        destroy_vm(uuid)

      deleted_identifier
    rescue => error
      Rails.logger.
        error "#{error.message} (#{error.class})\n#{error.backtrace.join("\n")}"
      false
    end
  end
end
