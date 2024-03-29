class KuberKit::EnvFileReader::Reader
  ReaderNotFoundError = Class.new(KuberKit::NotFoundError)
  
  def use_reader(env_file_reader, env_file_class:)
    @@readers ||= {}

    if !env_file_reader.is_a?(KuberKit::EnvFileReader::Strategies::Abstract)
      raise ArgumentError.new("should be an instance of KuberKit::EnvFileReader::Strategies::Abstract, got: #{env_file_reader.inspect}")
    end

    @@readers[env_file_class] = env_file_reader
  end

  def read(shell, env_file)
    reader = @@readers[env_file.class]

    raise ReaderNotFoundError, "Can't find reader for env file #{env_file}" if reader.nil?

    reader.read(shell, env_file)
  end
end