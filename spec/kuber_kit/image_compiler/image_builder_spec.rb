RSpec.describe KuberKit::ImageCompiler::ImageBuilder do
  subject{ KuberKit::ImageCompiler::ImageBuilder.new }

  let(:image) { test_helper.image(:example) }
  let(:shell) { test_helper.shell }

  class TestVersionTagBuilder
    def get_version
      "202010.202010"
    end
  end

  before do
    KuberKit::Container.stub("image_compiler.version_tag_builder", TestVersionTagBuilder.new)
  end

  after do
    KuberKit::Container.unstub("image_compiler.version_tag_builder")
  end

  it "builds image using docker" do
    expect(subject.docker_commands).to receive(:build).with(shell, "/tmp/build/example", ["-t=default/example:latest"])
    subject.build(shell, image, "/tmp/build/example")
  end

  it "adds tag with remote registry url and version if registry is remote" do
    remote_image = test_helper.remote_image(:remote_image, "http://test.com")

    expect(subject.docker_commands).to receive(:tag).with(shell, "remote/remote_image:latest", "http://test.com/remote/remote_image:latest")
    subject.build(shell, remote_image, "/tmp/build/remote_image")
  end

  it "pushes image to registry" do
    remote_image = test_helper.remote_image(:remote_image, "http://test.com")

    expect(subject.docker_commands).to receive(:push).with(shell, "http://test.com/remote/remote_image:latest")
    subject.build(shell, remote_image, "/tmp/build/remote_image")
  end

  it "calls before and after callbacks" do
    before_counter = 0
    after_counter = 0

    image_def = test_helper.image_definition(:image)
      .before_build{ |context_helper, build_dir| before_counter += context_helper.hello_world.size }
      .after_build{ |context_helper, build_dir| after_counter += context_helper.hello_world.size }
    image = test_helper.image_factory.create(image_def)

    subject.build(shell, image, "/tmp/build/example", context_helper: test_helper.context_helper)

    expect(before_counter).to eq(11)
    expect(after_counter).to eq(11)
  end
end