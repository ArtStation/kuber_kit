RSpec.describe KuberKit::ImageCompiler::ActionHandler do
  subject{ KuberKit::ImageCompiler::ActionHandler.new }

  let(:image) { test_helper.image(:example) }
  let(:shell) { test_helper.shell }

  it "runs image compile by image name and returns compilation result" do
    expect(subject.image_store).to receive(:get_image).with(:example).and_return(image)
    expect(subject.compiler).to receive(:compile).with(shell, image, /kuber_kit\/image_builds\/2020/).and_return("image_id")

    result = subject.call(shell, :example, "2020")
    expect(result).to eq("image_id")
  end

  it "uses tmp folder for remote compilation" do
    remote_shell = test_helper.ssh_shell
    expect(subject.image_store).to receive(:get_image).with(:example).and_return(image)
    expect(subject.compiler).to receive(:compile).with(remote_shell, image, /kuber_kit\/image_builds\/2020/).and_return("image_id")

    result = subject.call(remote_shell, :example, "2020")
    expect(result).to eq("image_id")
  end
end