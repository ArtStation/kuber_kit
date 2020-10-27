RSpec.describe Indocker::ServiceHandler::ServiceReader do
  subject{ Indocker::ServiceHandler::ServiceReader.new }

  let(:artifact) { Indocker::Core::Artifacts::Local.new(:templates).setup(File.join(FIXTURES_PATH, "templates")) }
  let(:template) { Indocker::Core::Templates::ArtifactFile.new(:service_template, artifact_name: :templates, file_path: "service.yml") }
  let(:service_definition) { test_helper.service_definition(:auth_app).template(:service_template) }
  let(:service) { test_helper.service_factory.create(service_definition) }

  before do
    test_helper.artifact_store.add(artifact)
    test_helper.template_store.add(template)
  end

  xit "returns service config" do
    result = subject.read(test_helper.shell, service)
    expect(result).to eq("apiVersion: v1\nkind: Service\nmetadata:\n  configuration: \"default\"\nspec:\n  selector:\n    app: test-app")
  end
end