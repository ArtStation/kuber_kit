class KuberKit::Shell::Commands::DockerCommands
  def build(shell, build_dir, args = [])
    default_args = ["--rm=true"]
    args_list = (default_args + args).join(" ")

    shell.exec!(%Q{docker image build #{build_dir} #{args_list}}, merge_stderr: true)
  end

  def tag(shell, current_tag_name, new_tag_name)
    shell.exec!(%Q{docker tag #{current_tag_name} #{new_tag_name}}, merge_stderr: true)
  end

  def push(shell, tag_name)
    shell.exec!(%Q{docker push #{tag_name}}, merge_stderr: true)
  end

  def run(shell, image_name, args: nil, command: nil, detached: false, interactive: false)
    command_parts = []
    command_parts << "docker run"
    command_parts << "-d" if detached
    command_parts << Array(args).join(" ") if args
    command_parts << image_name
    command_parts << command if command

    if interactive
      shell.interactive!(command_parts.join(" "))
    else
      shell.exec!(command_parts.join(" "), merge_stderr: true)
    end
  end

  def container_exists?(shell, container_name, status: nil)
    result = get_containers(shell, container_name, status: status)
    result && result != ""
  end

  def get_containers(shell, container_name, only_healthy: false, status: nil)
    command_parts = []
    command_parts << "docker ps -a -q"

    if only_healthy
      command_parts << "--filter=\"health=healthy\""
    end
    if status
      command_parts << "--filter=\"status=#{status}\""
    end
    command_parts << "--filter=\"name=^/#{container_name}$\""

    shell.exec!(command_parts.join(" "))
  end

  def delete_container(shell, container_name)
    shell.exec!("docker rm -f #{container_name}")
  end

  def create_network(shell, name)
    unless network_exists?(shell, name)
      shell.exec!("docker network create #{name}")
    end
  end

  def network_exists?(shell, network_name)
    result = get_networks(shell, network_name)
    result && result != ""
  end

  def get_networks(shell, network_name)
    command_parts = []
    command_parts << "docker network ls"
    command_parts << "--filter=\"name=#{network_name}\""
    command_parts << "--format \"{{.Name}}\""

    shell.exec!(command_parts.join(" "))
  end

  def create_volume(shell, name)
    unless volume_exists?(shell, name)
      shell.exec!("docker volume create #{name}")
    end
  end

  def volume_exists?(shell, volume_name)
    result = get_volumes(shell, volume_name)
    result && result != ""
  end

  def get_volumes(shell, volume_name)
    command_parts = []
    command_parts << "docker volume ls"
    command_parts << "--filter=\"name=#{volume_name}\""
    command_parts << "--format \"{{.Name}}\""

    shell.exec!(command_parts.join(" "))
  end
end