class KuberKit::Core::ServiceFactory
  def create(definition)
    service_attrs = definition.to_service_attrs

    configuration_attributes = KuberKit.current_configuration.service_attributes(service_attrs.name)
    base_attributes = service_attrs.attributes || {}
    attributes = if KuberKit.deep_merge_service_attributes?
      deep_merge(base_attributes, configuration_attributes)
    else
      base_attributes.merge(configuration_attributes)
    end

    KuberKit::Core::Service.new(
      name:               service_attrs.name,
      initializers:       service_attrs.initializers,
      template_name:      service_attrs.template_name,
      tags:               service_attrs.tags,
      images:             service_attrs.images,
      attributes:         attributes,
      deployer_strategy:  service_attrs.deployer_strategy,
      generator_strategy: service_attrs.generator_strategy,
    )
  end

  private
    def deep_merge(base, override)
      base.merge(override) do |_key, a, b|
        a.is_a?(Hash) && b.is_a?(Hash) ? deep_merge(a, b) : b
      end
    end
end
