module FogExtensions
  module Fogdocker
    module Server
      extend ActiveSupport::Concern

      include ActionView::Helpers::NumberHelper

      def state
        state_running ? 'Running' : 'Stopped'
      end

      # Last time a container was started
      # WARNING: this doesn't mean the container has been running since then.
      def started_at
        attributes['state_started_at']
      end

      def image_friendly_name
        attributes['config_image']
      end

      def command
        c = []
        c += entrypoint if entrypoint.present?
        c += cmd if cmd.present?
        c.join(' ')
      end

      def poweroff
        service.vm_action(:id => id, :action => :kill)
      end

      def reset
        poweroff
        start
      end

      def vm_description
        _('%{cores} Cores and %{memory} memory') %
          { :cores => cpus, :memory => number_to_human_size(memory.to_i) }
      end
    end
  end
end
