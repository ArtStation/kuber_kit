RSpec.describe KuberKit::ImageCompiler::ImageBuildDirCreator do
  subject{ KuberKit::ImageCompiler::ImageBuildDirCreator.new }

  let(:image) { test_helper.image(:example) }
  let(:shell) { test_helper.shell }

  before do
    allow(subject.file_preprocessor).to receive(:compile)
    allow(shell).to receive(:write)
    allow(shell).to receive(:sync)
  end

  it "creates a build dir" do
    expect(subject.bash_commands).to receive(:rm_rf).with(shell, "/tmp/images/example")
    expect(subject.bash_commands).to receive(:mkdir_p).with(shell, "/tmp/images/example")

    subject.create(shell, image, "/tmp/images/example")
  end

  it "compiles dockerfile & build context" do
    expect(shell).to receive(:sync).with(
      "/images/example/build_context", "/tmp/images/example"
    )
    expect(shell).to receive(:sync).with(
      "/images/example/Dockerfile", "/tmp/images/example/Dockerfile"
    )
    expect(subject.file_preprocessor).to receive(:compile).with(
      shell, "/tmp/images/example/Dockerfile", context_helper: nil
    )

    subject.create(shell, image, "/tmp/images/example")
  end

  it "creates a docker ignore file" do
    KuberKit::Container["configs"].docker_ignore_list = ["Dockerfile", "tmp"]

    expect(shell).to receive(:write).with(
      "/tmp/images/example/.dockerignore", "Dockerfile\r\ntmp"
    )

    subject.create(shell, image, "/tmp/images/example")
  end
end