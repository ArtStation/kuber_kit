require 'thor'

class KuberKit::CLI < Thor
  APP_CONFIG_FILENAME = "config.rb".freeze

  class_option :path, :type => :string
  class_option :images_path, :type => :string
  class_option :infra_path, :type => :string
  class_option :configurations_path, :type => :string
  class_option :debug, :type => :boolean, aliases: ["-d"]
  class_option :configuration, :type => :string, aliases: ["-C"]

  desc "compile IMAGE_NAMES", "Compile image with IMAGE_NAMES (comma-separated)"
  def compile(image_names_str)
    setup(options)
    
    image_names = image_names_str.split(",").map(&:strip).map(&:to_sym)

    if KuberKit::Container['actions.configuration_loader'].call(options)
      result = KuberKit::Container['actions.image_compiler'].call(image_names, options)
    end

    logger = KuberKit::Container['tools.logger']
    if result
      logger.info("---------------------------")
      logger.info("Image compilation finished!")
      logger.info("---------------------------")
    else
      logger.info("-------------------------".red)
      logger.info("Image compilation failed!".red)
      logger.info("-------------------------".red)
    end
  end

  desc "deploy CONTEXT_NAME", "Deploy CONTEXT_NAME with kubectl"
  method_option :services,      :type => :array,    aliases: ["-s"]
  method_option :tags,          :type => :array,    aliases: ["-t"]
  method_option :skip_compile,  :type => :boolean,  aliases: ["-B"]
  def deploy
    setup(options)

    if KuberKit::Container['actions.configuration_loader'].call(options)
      result = KuberKit::Container['actions.service_deployer'].call(
        services:     options[:services] || [], 
        tags:         options[:tags] || [],
        skip_compile: options[:skip_compile] || false
      )
    end

    logger = KuberKit::Container['tools.logger']
    if result
      logger.info("---------------------------")
      logger.info("Service deployment finished!")
      logger.info("---------------------------")
    else
      logger.info("-------------------------".red)
      logger.info("Service deployment failed!".red)
      logger.info("-------------------------".red)
    end
  end

  desc "env ENV_FILE_NAME", "Return content of Env File ENV_FILE_NAME"
  def env(env_file_name)
    setup(options)

    if KuberKit::Container['actions.configuration_loader'].call(options)
      KuberKit::Container['actions.env_file_reader'].call(env_file_name.to_sym, options)
    end
  end

  desc "template TEMPLATE_NAME", "Return content of Template TEMPLATE_NAME"
  def template(template_name)
    setup(options)

    if KuberKit::Container['actions.configuration_loader'].call(options)
      KuberKit::Container['actions.template_reader'].call(template_name.to_sym, options)
    end
  end

  desc "service SERVICE_NAME", "Return content of Service SERVICE_NAME"
  def service(service_name)
    setup(options)

    if KuberKit::Container['actions.configuration_loader'].call(options)
      KuberKit::Container['actions.service_reader'].call(service_name.to_sym, options)
    end
  end

  desc "apply FILE_PATH", "Apply FILE_PATH with kubectl"
  def apply(file_path)
    setup(options)

    if KuberKit::Container['actions.configuration_loader'].call(options)
      KuberKit::Container['actions.kubectl_applier'].call(File.expand_path(file_path), options)
    end
  end

  desc "attach POD_NAME", "Attach to POD_NAME using kubectl"
  def attach(pod_name = nil)
    setup(options)

    if KuberKit::Container['actions.configuration_loader'].call(options)
      KuberKit::Container['actions.kubectl_attacher'].call(pod_name, options)
    end
  end

  desc "console POD_NAME", "Attach to POD_NAME using kubectl & launch bin/console"
  def console(pod_name = nil)
    setup(options)

    if KuberKit::Container['actions.configuration_loader'].call(options)
      KuberKit::Container['actions.kubectl_console'].call(pod_name, options)
    end
  end

  desc "logs POD_NAME", "Show logs for POD_NAME using kubectl"
  method_option :follow,  :type => :boolean,  aliases: ["-f"]
  def logs(pod_name = nil)
    setup(options)

    if KuberKit::Container['actions.configuration_loader'].call(options)
      KuberKit::Container['actions.kubectl_logs'].call(pod_name, options)
    end
  end

  desc "version", "Print current version"
  def version
    puts KuberKit::VERSION
  end

  def self.exit_on_failure?
    true
  end

  private
    def setup(options)
      KuberKit.set_debug_mode(options[:debug])

      # We should load config before loading any bean, to make sure that bean won't be built with default config
      root_path     = options[:path] || File.join(Dir.pwd, KuberKit::Container['configs'].kuber_kit_dirname)
      config_file_path = File.join(root_path, APP_CONFIG_FILENAME)
      if File.exists?(config_file_path)
        require config_file_path
      end
    end
end