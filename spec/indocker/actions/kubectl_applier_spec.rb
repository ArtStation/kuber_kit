RSpec.describe Indocker::Actions::KubectlApplier do
  subject{ Indocker::Actions::KubectlApplier.new }

  it "applies file using kubectl" do
    expect(subject.kubectl_commands).to receive(:apply_file).with(subject.local_shell, "/file/to/apply.yml", kubecfg_path: nil)
    subject.call("/file/to/apply.yml", {})
  end
end