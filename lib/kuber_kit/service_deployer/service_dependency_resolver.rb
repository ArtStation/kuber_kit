class KuberKit::ServiceDeployer::ServiceDependencyResolver < KuberKit::Core::Dependencies::AbstractDependencyResolver
  include KuberKit::Import[
    "core.service_store",
    "configs"
  ]
  
  def get_deps(service_name)
    service_store.get_definition(service_name).dependencies
  end

  def dependency_batch_size
    configs.compile_simultaneous_limit
  end
end