object @container

extends 'api/v2/containers/base'

attributes :command, :compute_resource_id, :compute_resource_name, :entrypoint,
           :cpu_set, :cpu_shares, :memory, :tty,
           :attach_stdin, :attach_stdout, :attach_stderr,
           :repository_name, :tag, :registry_id, :registry_name,
           :created_at, :updated_at
