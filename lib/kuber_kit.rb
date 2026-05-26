require "kuber_kit/version"
require 'ostruct'
require 'contracts'
require 'dry-auto_inject'
require 'dry/container'
require 'kuber_kit/extensions/colored_string'
require 'kuber_kit/extensions/contracts'
require 'kuber_kit/extensions/tty_prompt'

$LOAD_PATH << File.join(__dir__, 'kuber_kit')

module KuberKit
  Error = Class.new(StandardError)
  NotImplementedError = Class.new(Error)
  NotFoundError = Class.new(Error)

  module Core
    autoload :ArtifactPath, 'core/artifact_path'
    autoload :ArtifactPathResolver, 'core/artifact_path_resolver'

    autoload :ImageDefinition, 'core/image_definition'
    autoload :ImageDefinitionFactory, 'core/image_definition_factory'
    autoload :ImageStore, 'core/image_store'
    autoload :ImageFactory, 'core/image_factory'
    autoload :Image, 'core/image'

    autoload :ServiceDefinition, 'core/service_definition'
    autoload :ServiceDefinitionFactory, 'core/service_definition_factory'
    autoload :ServiceStore, 'core/service_store'
    autoload :ServiceFactory, 'core/service_factory'
    autoload :Service, 'core/service'

    autoload :ConfigurationDefinition, 'core/configuration_definition'
    autoload :ConfigurationDefinitionFactory, 'core/configuration_definition_factory'
    autoload :ConfigurationStore, 'core/configuration_store'
    autoload :ConfigurationFactory, 'core/configuration_factory'
    autoload :Configuration, 'core/configuration'

    autoload :Store, 'core/store'

    module Artifacts
      autoload :AbstractArtifact, 'core/artifacts/abstract_artifact'
      autoload :ArtifactStore, 'core/artifacts/artifact_store'
      autoload :Git, 'core/artifacts/git'
      autoload :Local, 'core/artifacts/local'
    end

    module BuildServers
      autoload :AbstractBuildServer, 'core/build_servers/abstract_build_server'
      autoload :BuildServerStore, 'core/build_servers/build_server_store'
      autoload :BuildServer, 'core/build_servers/build_server'
    end

    module Dependencies
      autoload :AbstractDependencyResolver, 'core/dependencies/abstract_dependency_resolver'
    end

    module EnvFiles
      autoload :EnvFileStore, 'core/env_files/env_file_store'
      autoload :AbstractEnvFile, 'core/env_files/abstract_env_file'
      autoload :ArtifactFile, 'core/env_files/artifact_file'
      autoload :EnvGroup, 'core/env_files/env_group'
    end

    module ContextHelper
      autoload :AbstractHelper, 'core/context_helper/abstract_helper'
      autoload :BaseHelper, 'core/context_helper/base_helper'
      autoload :ImageHelper, 'core/context_helper/image_helper'
      autoload :ServiceHelper, 'core/context_helper/service_helper'
      autoload :ContextHelperFactory, 'core/context_helper/context_helper_factory'
      autoload :ContextVars, 'core/context_helper/context_vars'
      autoload :LocalContextHelper, 'core/context_helper/local_context_helper'
    end

    module Registries
      autoload :AbstractRegistry, 'core/registries/abstract_registry'
      autoload :RegistryStore, 'core/registries/registry_store'
      autoload :Registry, 'core/registries/registry'
    end

    module Templates
      autoload :TemplateStore, 'core/templates/template_store'
      autoload :AbstractTemplate, 'core/templates/abstract_template'
      autoload :ArtifactFile, 'core/templates/artifact_file'
    end
  end

  module Tools
    autoload :BuildDirCleaner, 'tools/build_dir_cleaner'
    autoload :FilePresenceChecker, 'tools/file_presence_checker'
    autoload :LoggerFactory, 'tools/logger_factory'
    autoload :ProcessCleaner, 'tools/process_cleaner'
    autoload :WorkdirDetector, 'tools/workdir_detector'
  end

  module Shell
    autoload :AbstractShell, 'shell/abstract_shell'
    autoload :LocalShell, 'shell/local_shell'
    autoload :SshShell, 'shell/ssh_shell'
    autoload :SshSession, 'shell/ssh_session'
    autoload :CommandCounter, 'shell/command_counter'

    module Commands
      autoload :BashCommands, 'shell/commands/bash_commands'
      autoload :DockerCommands, 'shell/commands/docker_commands'
      autoload :DockerComposeCommands, 'shell/commands/docker_compose_commands'
      autoload :GitCommands, 'shell/commands/git_commands'
      autoload :RsyncCommands, 'shell/commands/rsync_commands'
      autoload :KubectlCommands, 'shell/commands/kubectl_commands'
      autoload :SystemCommands, 'shell/commands/system_commands'
      autoload :HelmCommands, 'shell/commands/helm_commands'
    end
  end

  module ImageCompiler
    autoload :ActionHandler, 'image_compiler/action_handler'
    autoload :BuildServerPool, 'image_compiler/build_server_pool'
    autoload :BuildServerPoolFactory, 'image_compiler/build_server_pool_factory'
    autoload :Compiler, 'image_compiler/compiler'
    autoload :ImageBuilder, 'image_compiler/image_builder'
    autoload :ImageBuildDirCreator, 'image_compiler/image_build_dir_creator'
    autoload :ImageDependencyResolver, 'image_compiler/image_dependency_resolver'
    autoload :VersionTagBuilder, 'image_compiler/version_tag_builder'
  end

  module Preprocessing
    autoload :TextPreprocessor, 'preprocessing/text_preprocessor'
    autoload :FilePreprocessor, 'preprocessing/file_preprocessor'
  end

  module ArtifactsSync
    autoload :ArtifactUpdater, 'artifacts_sync/artifact_updater'

    module Strategies
      autoload :Abstract, 'artifacts_sync/strategies/abstract'
      autoload :GitUpdater, 'artifacts_sync/strategies/git_updater'
      autoload :NullUpdater, 'artifacts_sync/strategies/null_updater'
    end
  end

  module EnvFileReader
    autoload :ActionHandler, 'env_file_reader/action_handler'
    autoload :Reader, 'env_file_reader/reader'
    autoload :EnvFileParser, 'env_file_reader/env_file_parser'
    autoload :EnvFileTempfileCreator, 'env_file_reader/env_file_tempfile_creator'

    module Strategies
      autoload :Abstract, 'env_file_reader/strategies/abstract'
      autoload :ArtifactFile, 'env_file_reader/strategies/artifact_file'
      autoload :EnvGroup, 'env_file_reader/strategies/env_group'
    end
  end

  module TemplateReader
    autoload :ActionHandler, 'template_reader/action_handler'
    autoload :Reader, 'template_reader/reader'
    autoload :Renderer, 'template_reader/renderer'

    module Strategies
      autoload :Abstract, 'template_reader/strategies/abstract'
      autoload :ArtifactFile, 'template_reader/strategies/artifact_file'
    end
  end

  module ServiceDeployer
    autoload :ActionHandler, 'service_deployer/action_handler'
    autoload :StrategyDetector, 'service_deployer/strategy_detector'
    autoload :Deployer, 'service_deployer/deployer'
    autoload :DeploymentOptionsSelector, 'service_deployer/deployment_options_selector'
    autoload :ServiceListResolver, 'service_deployer/service_list_resolver'
    autoload :ServiceDependencyResolver, 'service_deployer/service_dependency_resolver'

    module Strategies
      autoload :Abstract, 'service_deployer/strategies/abstract'
      autoload :Docker, 'service_deployer/strategies/docker'
      autoload :DockerCompose, 'service_deployer/strategies/docker_compose'
      autoload :Kubernetes, 'service_deployer/strategies/kubernetes'
      autoload :Helm, 'service_deployer/strategies/helm'
    end
  end

  module ServiceGenerator
    autoload :ActionHandler, 'service_generator/action_handler'
    autoload :StrategyDetector, 'service_generator/strategy_detector'
    autoload :Generator, 'service_generator/generator'

    module Strategies
      autoload :Abstract, 'service_generator/strategies/abstract'
      autoload :Helm, 'service_generator/strategies/helm'
    end
  end

  module ServiceReader
    autoload :ActionHandler, 'service_reader/action_handler'
    autoload :Reader, 'service_reader/reader'
  end

  module ShellLauncher
    autoload :ActionHandler, 'shell_launcher/action_handler'
    autoload :Launcher, 'shell_launcher/launcher'

    module Strategies
      autoload :Abstract, 'shell_launcher/strategies/abstract'
      autoload :Kubernetes, 'shell_launcher/strategies/kubernetes'
    end
  end

  module Actions
    autoload :ActionResult, 'actions/action_result'
    autoload :ImageCompiler, 'actions/image_compiler'
    autoload :EnvFileReader, 'actions/env_file_reader'
    autoload :TemplateReader, 'actions/template_reader'
    autoload :ServiceReader, 'actions/service_reader'
    autoload :ServiceDeployer, 'actions/service_deployer'
    autoload :ServiceChecker, 'actions/service_checker'
    autoload :ServiceGenerator, 'actions/service_generator'
    autoload :ConfigurationLoader, 'actions/configuration_loader'
    autoload :KubectlApplier, 'actions/kubectl_applier'
    autoload :KubectlAttacher, 'actions/kubectl_attacher'
    autoload :KubectlConsole, 'actions/kubectl_console'
    autoload :KubectlDescribe, 'actions/kubectl_describe'
    autoload :KubectlGet, 'actions/kubectl_get'
    autoload :KubectlLogs, 'actions/kubectl_logs'
    autoload :KubectlEnv, 'actions/kubectl_env'
    autoload :ShellLauncher, 'actions/shell_launcher'
  end

  module Extensions
    autoload :Inspectable, 'extensions/inspectable'
  end

  module Kubernetes
    autoload :ResourceSelector, 'kubernetes/resource_selector'
    autoload :ResourcesFetcher, 'kubernetes/resources_fetcher'
    autoload :Resources, 'kubernetes/resources'
  end

  module UI
    autoload :Interactive, 'ui/interactive'
    autoload :Simple, 'ui/simple'
    autoload :Debug, 'ui/debug'
    autoload :Api, 'ui/api'
  end

  autoload :CLI, 'cli'
  autoload :Container, 'container'
  autoload :Configs, 'configs'
  autoload :Defaults, 'defaults'

  Import = Dry::AutoInject(Container)

  class << self
    def define_image(image_name)
      image_path = caller[0].split(':').first

      Container["core.image_store"].define(image_name, image_path.split('image.rb').first)
    end

    def define_service(service_name)
      Container["core.service_store"].define(service_name)
    end

    def define_configuration(configuration_name)
      Container["core.configuration_store"].define(configuration_name)
    end

    def set_configuration_name(configuration_name)
      @configuration_name = configuration_name.to_sym
      @current_configuration = nil
    end

    def set_ui_mode(value)
      @ui_mode = value
    end

    def ui_mode
      @ui_mode
    end

    def deprecation_warnings_disabled?
      Container["configs"].deprecation_warnings_disabled
    end

    def deep_merge_service_attributes?
      Container["configs"].deep_merge_service_attributes
    end

    def current_configuration
      if @configuration_name.nil?
        raise "Please set configuration name before calling current_configuration"
      end
      @current_configuration ||= Container['core.configuration_store'].get_configuration(@configuration_name)
    end

    def global_build_vars
      KuberKit::Core::ContextHelper::ContextVars.new(current_configuration.global_build_vars)
    end

    def add_registry(registry)
      Container["core.registry_store"].add(registry)
    end

    def add_artifact(artifact)
      Container["core.artifact_store"].add(artifact)
    end

    def add_env_file(env_file)
      Container["core.env_file_store"].add(env_file)
    end

    def add_template(template)
      Container["core.template_store"].add(template)
    end

    def add_build_server(build_server)
      Container["core.build_server_store"].add(build_server)
    end

    def build_helper(&proc)
      KuberKit::Core::ContextHelper::BaseHelper.class_exec(&proc)
    end

    def set_user(value)
      @user    = value
      @user_id = nil
    end

    def user
      @user ||= ENV["KUBER_KIT_USERNAME"] || `whoami`.chomp
    end

    def user_id
      @user_id ||= `id -u #{user}`.chomp
    end

    def configure(&proc)
      yield(Container["configs"])
    end
  end
end

KuberKit::Defaults.init

require 'kuber_kit/extensions/indocker_compat'
