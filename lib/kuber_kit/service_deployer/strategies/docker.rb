class KuberKit::ServiceDeployer::Strategies::Docker < KuberKit::ServiceDeployer::Strategies::Abstract
  include KuberKit::Import[
    "env_file_reader.env_file_tempfile_creator",
    "shell.docker_commands",
    "core.env_file_store",
    "core.image_store",
    "configs",
  ]

  STRATEGY_OPTIONS = [
    :namespace,
    :container_name,
    :env_file,
    :image_name,
    :detached,
    :command_name,
    :custom_args,
    :delete_if_exists,
    :volumes,
    :networks,
    :expose,
    :publish,
    :env_file_names,
    :env_vars
  ]

  Contract KuberKit::Shell::AbstractShell, KuberKit::Core::Service => Any
  def deploy(shell, service)
    strategy_options = service.attribute(:deployer, default: {})
    unknown_options  = strategy_options.keys.map(&:to_sym) - STRATEGY_OPTIONS
    if unknown_options.any?
      raise KuberKit::Error, "Unknown options for deploy strategy: #{unknown_options}. Available options: #{STRATEGY_OPTIONS}"
    end
    
    namespace       = strategy_options.fetch(:namespace, nil)
    container_name  = strategy_options.fetch(:container_name, [namespace, service.name].compact.join("_"))
    command_name    = strategy_options.fetch(:command_name, nil)
    custom_env_file = strategy_options.fetch(:env_file, nil)
    custom_args     = strategy_options.fetch(:custom_args, nil)
    networks        = strategy_options.fetch(:networks, [])
    volumes         = strategy_options.fetch(:volumes, [])
    expose_ports    = strategy_options.fetch(:expose, [])
    publish_ports   = strategy_options.fetch(:publish, [])
    hostname        = strategy_options.fetch(:hostname, container_name)

    env_file_names  = strategy_options.fetch(:env_file_names, [])
    env_files       = prepare_env_files(shell, env_file_names)
    env_vars        = strategy_options.fetch(:env_vars, {})

    image_name = strategy_options.fetch(:image_name, nil)
    if image_name.nil?
      raise KuberKit::Error, "image_name is mandatory attribute for this deploy strategy"
    end
    image = image_store.get_image(image_name.to_sym)

    delete_enabled = strategy_options.fetch(:delete_if_exists, false)
    if delete_enabled && docker_commands.container_exists?(shell, container_name)
      docker_commands.delete_container(shell, container_name)
    end

    custom_args = Array(custom_args)
    if container_name
      custom_args << "--name #{container_name}"
    end
    if custom_env_file
      custom_args << "--env-file #{custom_env_file}"
    end
    if hostname
      custom_args << "--hostname #{hostname}"
    end
    networks.each do |network|
      docker_commands.create_network(shell, network)
      custom_args << "--network #{network}"
    end
    volumes.each do |volume|
      volume_name, _ = volume.split(":")
      docker_commands.create_volume(shell, volume_name) unless volume_name.start_with?("/")
      custom_args << "--volume #{volume}"
    end
    Array(expose_ports).each do |expose_port|
      custom_args << "--expose #{expose_port}"
    end
    Array(publish_ports).each do |publish_port|
      custom_args << "--publish #{publish_port}"
    end
    Array(env_files).each do |env_file|
      custom_args << "--env-file #{env_file}"
    end
    env_vars.each do |key, value|
      custom_args << "--env #{key}=#{value}"
    end

    docker_commands.run(
      shell, image.remote_registry_url, 
      command:      command_name,
      args:         custom_args, 
      detached:     !!strategy_options[:detached],
      interactive:  !strategy_options[:detached]
    )
  end

  private
    def prepare_env_files(shell, env_file_names)
      env_files = env_file_names.map do |env_file_name|
        env_file_store.get(env_file_name)
      end
      env_files.map do |env_file|
        env_file_tempfile_creator.call(shell, env_file)
      end
    end
end