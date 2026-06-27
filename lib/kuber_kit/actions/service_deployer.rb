class KuberKit::Actions::ServiceDeployer
  include KuberKit::Import[
    "actions.image_compiler",
    "service_deployer.service_list_resolver",
    "service_deployer.service_dependency_resolver",
    "service_deployer.deployment_options_selector",
    "core.service_store",
    "shell.local_shell",
    "tools.process_cleaner",
    "configs",
    "ui",
    service_deployer: "service_deployer.action_handler",
  ]

  Contract KeywordArgs[
    services:             Maybe[ArrayOf[String]],
    tags:                 Maybe[ArrayOf[String]],
    skip_services:        Maybe[ArrayOf[String]],
    skip_compile:         Maybe[Bool],
    skip_dependencies:    Maybe[Bool],
    skip_deployment:      Maybe[Bool],
    require_confirmation: Maybe[Bool],
  ] => Any
  def call(services:, tags:, skip_services: nil, skip_compile: false, skip_dependencies: false, skip_deployment: false, require_confirmation: false)
    deployment_result     = KuberKit::Actions::ActionResult.new()
    current_configuration = KuberKit.current_configuration

    if services.empty? && tags.empty?
      services, tags = deployment_options_selector.call()
    end

    disabled_services     = current_configuration.disabled_services.map(&:to_s)
    disabled_services     += skip_services if skip_services
    default_services      = current_configuration.default_services.map(&:to_s) - disabled_services
    pre_deploy_services   = current_configuration.pre_deploy_services.map(&:to_s) - disabled_services
    post_deploy_services  = current_configuration.post_deploy_services.map(&:to_s) - disabled_services

    service_names = service_list_resolver.resolve(
      services:         services || [],
      tags:             tags || [],
      enabled_services:   current_configuration.enabled_services.map(&:to_s),
      disabled_services:  disabled_services,
      default_services:   default_services
    ).map(&:to_sym)

    # Return the list of services with all dependencies.
    if skip_dependencies
      all_service_names = service_names
    else
      all_service_names = service_dependency_resolver.get_all(service_names)
    end

    all_service_names_with_hooks  = (pre_deploy_services.map(&:to_sym) + all_service_names + post_deploy_services.map(&:to_sym)).uniq

    unless all_service_names.any?
      ui.print_warning "ServiceDeployer", "No service found with given options, nothing will be deployed."
      return false
    end

    unless allow_deployment?(require_confirmation: require_confirmation, service_names: all_service_names_with_hooks)
      return false
    end

    # Compile images for all services and dependencies
    images_names = get_image_names(service_names: all_service_names_with_hooks.uniq)
    unless skip_compile
      compilation_result = compile_images(images_names)

      return false unless compilation_result && compilation_result.succeeded?
    end

    # Skip service deployment, only compile images.
    if skip_deployment
      return deployment_result
    end

    # First, deploy pre-deploy services.
    # This feature is used to deploy some services, required for deployment of other services, e.g. env files
    # Note: Initial services are deployed without dependencies
    pre_deploy_services.map(&:to_sym).each_slice(configs.deploy_simultaneous_limit) do |batch_service_names|
      deploy_simultaneously(batch_service_names, deployment_result)
    end

    # Next, deploy all initializers simultaneously.
    # Note: In earlier versions, KuberKit would deploy all dependencies in the order defined by dependency tree.
    #       Now it would deploy all dependencies (initializers) at the same time, even if one initializer depends on another initializer.
    unless skip_dependencies
      initializers = service_dependency_resolver.get_all_deps(service_names)
      initializers.map(&:to_sym).each_slice(configs.deploy_simultaneous_limit) do |batch_service_names|
        deploy_simultaneously(batch_service_names, deployment_result)
      end
      service_names -= initializers
    end

    # Next, deploy all requested services, except initializers.
    service_names.each_slice(configs.deploy_simultaneous_limit) do |batch_service_names|
      deploy_simultaneously(batch_service_names, deployment_result)
    end

    # Last, deploy post-deploy services.
    post_deploy_services.map(&:to_sym).each_slice(configs.deploy_simultaneous_limit) do |batch_service_names|
      deploy_simultaneously(batch_service_names, deployment_result)
    end

    deployment_result
  rescue KuberKit::Error => e
    ui.print_error("Error", e.message)

    deployment_result.failed!(e.message)
    
    false
  rescue Interrupt => e
    process_cleaner.clean

    false
  end

  private
    def deploy_simultaneously(service_names, deployment_result)
      unless deployment_result.succeeded?
        ui.print_debug("ServiceDeployer", "Deployment already failed. Canceling: #{service_names.inspect}")
        return
      end

      ui.print_debug("ServiceDeployer", "Scheduling to deploy: #{service_names.inspect}. Limit: #{configs.deploy_simultaneous_limit}")

      task_group = ui.create_task_group

      service_names.each do |service_name|

        ui.print_debug("ServiceDeployer", "Started deploying: #{service_name.to_s.green}")
        task_group.add("Deploying #{service_name.to_s.yellow}") do |task|
          deployment_result.start_task(service_name)
          service_result = service_deployer.call(local_shell, service_name.to_sym)
          deployment_result.finish_task(service_name, service_result)

          task.update_title("Deployed #{service_name.to_s.green}")
          ui.print_debug("ServiceDeployer", "Finished deploying: #{service_name.to_s.green}")
        end
      end

      task_group.wait
    end

    def compile_images(images_names)
      return KuberKit::Actions::ActionResult.new if images_names.empty?
      image_compiler.call(images_names, {})
    end

    def get_image_names(service_names:)
      services = service_names.map do |service_name|
        service_store.get_service(service_name.to_sym)
      end
  
      services.map(&:images).flatten.uniq
    end

    def allow_deployment?(require_confirmation:, service_names:)
      services_list = service_names.map(&:to_s).map(&:yellow).join(", ")
      ui.print_info "ServiceDeployer", "The following services will be deployed: #{services_list}"

      unless require_confirmation
        return true
      end

      result = ui.prompt("Please confirm to continue deployment", ["confirm".green, "cancel".red])
      return ["confirm".green, "confirm", "yes"].include?(result)
    end
end