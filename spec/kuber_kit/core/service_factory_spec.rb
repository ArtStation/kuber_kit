require 'spec_helper'

RSpec.describe KuberKit::Core::ServiceFactory do
  subject{ KuberKit::Core::ServiceFactory.new() }
  let(:test_definition) { service_helper.definition(:example).template(:service) }
  let(:configuration_definition) { test_helper.configuration_store.get_definition(:default) }
  let(:configs) { KuberKit::Container['configs'] }

  it "builds image based on image definition" do
    service = subject.create(test_definition)

    expect(service).to be_a(KuberKit::Core::Service)
    expect(service.name).to eq(:example)
  end

  context "merging configuration service_attributes with definition attributes" do
    let(:definition_with_attrs) do
      service_helper.definition(:example)
        .template(:service)
        .attributes(env: { FOO: "1", BAR: "2" }, scale: 1)
    end

    context "with deep_merge_service_attributes disabled (default)" do
      it "shallow-merges, replacing nested hashes entirely" do
        configuration_definition.service_attributes(example: { env: { FOO: "X" } })

        service = subject.create(definition_with_attrs)

        expect(service.attributes).to eq(env: { FOO: "X" }, scale: 1)
      end
    end

    context "with deep_merge_service_attributes enabled" do
      before { configs.deep_merge_service_attributes = true }

      it "deep-merges nested hashes, preserving sibling keys" do
        configuration_definition.service_attributes(example: { env: { FOO: "X" } })

        service = subject.create(definition_with_attrs)

        expect(service.attributes).to eq(env: { FOO: "X", BAR: "2" }, scale: 1)
      end

      it "overrides top-level scalar values" do
        configuration_definition.service_attributes(example: { scale: 5 })

        service = subject.create(definition_with_attrs)

        expect(service.attributes).to eq(env: { FOO: "1", BAR: "2" }, scale: 5)
      end

      it "replaces arrays rather than concatenating them" do
        definition_with_array = service_helper.definition(:example)
          .template(:service)
          .attributes(hosts: ["a", "b"])
        configuration_definition.service_attributes(example: { hosts: ["c"] })

        service = subject.create(definition_with_array)

        expect(service.attributes).to eq(hosts: ["c"])
      end
    end
  end
end
