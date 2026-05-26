# frozen_string_literal: true

class KuberKit::Configs
  AVAILABLE_CONFIGS = [
    :image_dockerfile_name, :image_build_context_dir, :image_tag, :docker_ignore_list, :image_compile_dir, :remote_image_compile_dir,
    :kuber_kit_dirname, :kuber_kit_min_version, :images_dirname, :services_dirname, :infra_dirname, :configurations_dirname,
    :artifact_clone_dir, :service_config_dir, :deployer_strategy, :compile_simultaneous_limit, :deploy_simultaneous_limit,
    :additional_images_paths, :deprecation_warnings_disabled, :log_file_path, :env_file_compile_dir, :shell_launcher_strategy,
    :shell_launcher_sets_configration, :generator_strategy, :deep_merge_service_attributes
  ]
  DOCKER_IGNORE_LIST = [
    'Dockerfile',
    '.DS_Store',
    '**/.DS_Store',
    '**/*.log',
    'node_modules',
    '.vagrant',
    '.vscode',
    'tmp',
    'logs'
  ]

  AVAILABLE_CONFIGS.each do |config_name|
    define_method(config_name) do
      get(config_name.to_sym)
    end

    define_method(:"#{config_name}=") do |value|
      set(config_name.to_sym, value)
    end
  end

  def initialize
    add_default_configs unless items.any?
  end

  def add_default_configs
    home_kuber_kit_path = File.join("~", ".kuber_kit")
    absolute_kuber_kit_path = File.expand_path(home_kuber_kit_path)
    
    set :image_dockerfile_name,   "Dockerfile"
    set :image_build_context_dir, "build_context"
    set :image_tag,               'latest'
    set :image_compile_dir,         File.join(absolute_kuber_kit_path, "image_builds")
    set :remote_image_compile_dir,  File.join("/tmp", "kuber_kit", "image_builds")
    set :docker_ignore_list,      DOCKER_IGNORE_LIST
    set :kuber_kit_dirname,       "kuber_kit"
    set :kuber_kit_min_version,   KuberKit::VERSION
    set :images_dirname,          "images"
    set :services_dirname,        "services"
    set :infra_dirname,           "infrastructure"
    set :configurations_dirname,  "configurations"
    set :artifact_clone_dir,      File.join(absolute_kuber_kit_path, "artifacts")
    set :service_config_dir,      File.join(absolute_kuber_kit_path, "services")
    set :deployer_strategy,         :kubernetes
    set :shell_launcher_strategy,   :kubernetes
    set :compile_simultaneous_limit, 5
    set :deploy_simultaneous_limit,  5
    set :additional_images_paths, []
    set :deprecation_warnings_disabled, false
    set :deep_merge_service_attributes, false
    set :log_file_path,           File.join(absolute_kuber_kit_path, "deploy.log")
    set :env_file_compile_dir,    File.join(absolute_kuber_kit_path, "env_files")
    set :shell_launcher_sets_configration, true
    set :generator_strategy,         :helm
  end

  def items
    @@items ||= {}
  end

  def set(key, value)
    unless AVAILABLE_CONFIGS.include?(key)
      raise ArgumentError, "#{key} is not a valid configuration key"
    end

    items[key] = value
  end

  def get(key)
    unless AVAILABLE_CONFIGS.include?(key)
      raise ArgumentError, "#{key} is not a valid configuration key"
    end

    items[key]
  end

  def reset!
    @@items = {}
  end
end