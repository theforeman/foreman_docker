# To be replaced by find_resource, FindCommon after 1.6 support is deprecated
module ForemanDocker
  module FindContainer
    extend ActiveSupport::Concern

    def find_container
      if params[:id].blank?
        not_found
        return
      end
      @container = Container.authorized("#{action_permission}_#{controller_name}".to_sym)
                   .find(params[:id])
    end

    def allowed_resources
      ForemanDocker::Docker.authorized(:view_compute_resources)
    end
  end
end
