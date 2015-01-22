module Service
  module Actions
    module ComputeResource
      class Pull < ::Actions::EntryAction
        def plan(container)
          #container.disable_auto_reindex!
          action_subject(container)
          container.compute_resource.create_image(:fromImage => container.repository_pull_url)
        end

        def humanized_name
          _('Pull')
        end

        def finalize
          logger.info('Finished pulling Docker image')
        end
      end
    end
  end
end
