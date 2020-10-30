class KuberKit::EnvFileReader::AbstractEnvFileReader
  def read(shell, env_file)
    raise KuberKit::NotImplementedError, "must be implemented"
  end
end