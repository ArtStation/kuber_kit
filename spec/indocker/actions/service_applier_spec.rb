RSpec.describe Indocker::Actions::ServiceApplier do
  subject{ Indocker::Actions::ServiceApplier.new }

  let(:shell) { test_helper.shell }
  let(:artifact) { Indocker::Core::Artifacts::Local.new(:templates).setup(File.join(FIXTURES_PATH, "templates")) }
  let(:template) { Indocker::Core::Templates::ArtifactFile.new(:service, artifact_name: :templates, file_path: "service.yml") }

  before do
    test_helper.artifact_store.add(artifact)
    test_helper.template_store.add(template)

    test_helper.service_store.define(:auth_app).template(:service)
  end

  it "prints content of service config" do
    expect(subject.local_shell).to receive(:write).with("/tmp/indocker/services/auth_app.yml", /apiVersion: v1/)
    expect(subject.kubectl_commands).to receive(:apply_file).with(subject.local_shell, "/tmp/indocker/services/auth_app.yml", kubecfg_path: nil)
    subject.call(:auth_app, {})
  end
end