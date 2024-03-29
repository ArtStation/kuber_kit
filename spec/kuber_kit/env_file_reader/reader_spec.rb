RSpec.describe KuberKit::EnvFileReader::Reader do
  subject{ KuberKit::EnvFileReader::Reader.new }

  class ExampleReader < KuberKit::EnvFileReader::Strategies::Abstract
    def read(shell, env_file)
      return {name: env_file.name}
    end
  end

  class ExampleEnvFile1 < KuberKit::Core::EnvFiles::AbstractEnvFile
  end

  class ExampleEnvFile2 < KuberKit::Core::EnvFiles::AbstractEnvFile
  end

  class ExampleEnvFile3 < KuberKit::Core::EnvFiles::AbstractEnvFile
  end

  let(:reader1) { ExampleReader.new }
  let(:reader2) { ExampleReader.new }
  let(:env_file1) { ExampleEnvFile1.new(:env_file1) }
  let(:env_file2) { ExampleEnvFile2.new(:env_file2) }
  let(:env_file3) { ExampleEnvFile3.new(:env_file3) }

  it "calls the reader for this env file type on read" do
    subject.use_reader(reader1, env_file_class: ExampleEnvFile1)
    subject.use_reader(reader2, env_file_class: ExampleEnvFile2)

    result1 = subject.read(test_helper.shell, env_file1)
    result2 = subject.read(test_helper.shell, env_file2)

    expect(result1[:name]).to eq(:env_file1)
    expect(result2[:name]).to eq(:env_file2)
  end

  it "raises error if reader not found for class" do
    expect {
      subject.read(test_helper.shell, env_file3)
    }.to raise_error(KuberKit::EnvFileReader::Reader::ReaderNotFoundError)
  end

  it "raises an error if reader is not an instance of abstract reader" do
    expect {
      subject.use_reader(KuberKit, artifact_class: ExampleArtifact1)
  }.to raise_error(ArgumentError)
  end
end