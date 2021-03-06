require 'spec_helper'

RSpec.describe KuberKit::Core::ImageDefinition do
  subject{ KuberKit::Core::ImageDefinition.new(:example_image, "/images/example_image") }

  context "initialize" do
    it "can initialize image with symbol name" do
      definition = KuberKit::Core::ImageDefinition.new(:example_image, "")
      expect(definition.image_name).to eq(:example_image)
    end

    it "can initialize image with string name" do
      definition = KuberKit::Core::ImageDefinition.new("example_image", "")
      expect(definition.image_name).to eq(:example_image)
    end
  end

  context "dependencies" do
    it "sets image dependencies with symbol" do
      definition = subject.depends_on(:another_image)
  
      expect(definition.to_image_attrs.dependencies).to eq([:another_image])
    end

    it "sets image dependencies with array" do
      definition = subject.depends_on([:first_image, :second_image])
  
      expect(definition.to_image_attrs.dependencies).to eq([:first_image, :second_image])
    end

    it "sets image dependencies with multiple args" do
      definition = subject.depends_on(:first_image, :second_image)
  
      expect(definition.to_image_attrs.dependencies).to eq([:first_image, :second_image])
    end
  end

  context "registry" do
    it "sets image registry with symbol" do
      definition = subject.registry(:default)
  
      expect(definition.to_image_attrs.registry_name).to eq(:default)
    end

    it "sets image registry with proc" do
      definition = subject.registry{ :default }
  
      expect(definition.to_image_attrs.registry_name).to eq(:default)
    end
  end

  context "dockerfile" do
    it "sets dockerfile path with symbol" do
      definition = subject.dockerfile("/path/to/dockerfile")
  
      expect(definition.to_image_attrs.dockerfile_path).to eq("/path/to/dockerfile")
    end

    it "sets dockerfile path with proc" do
      definition = subject.dockerfile{ "/path/to/dockerfile" }
  
      expect(definition.to_image_attrs.dockerfile_path).to eq("/path/to/dockerfile")
    end
  end

  context "build_vars" do
    it "sets build_vars with symbol" do
      definition = subject.build_vars({health_check_url: "/test"})
  
      expect(definition.to_image_attrs.build_vars).to eq({health_check_url: "/test"})
    end

    it "sets build_vars with proc" do
      definition = subject.build_vars{ {health_check_url: "/test"} }
  
      expect(definition.to_image_attrs.build_vars).to eq({health_check_url: "/test"})
    end

    it "DEPRECATED: sets build_vars as build_args" do
      definition = subject.build_args({health_check_url: "/test"})
  
      expect(definition.to_image_attrs.build_vars).to eq({health_check_url: "/test"})
    end
  end

  context "build_context" do
    it "sets build_context dir with symbol" do
      definition = subject.build_context("/some/dir")
  
      expect(definition.to_image_attrs.build_context_dir).to eq("/some/dir")
    end

    it "sets build_context dir with proc" do
      definition = subject.build_context{ "/some/dir" }
  
      expect(definition.to_image_attrs.build_context_dir).to eq("/some/dir")
    end
  end

  context "tag" do
    it "sets tag with symbol" do
      definition = subject.tag("latest")
  
      expect(definition.to_image_attrs.tag).to eq("latest")
    end

    it "sets tag with proc" do
      definition = subject.tag{ "latest" }
  
      expect(definition.to_image_attrs.tag).to eq("latest")
    end
  end

  context "before_build" do
    it "saves before_build as proc" do
      definition = subject.before_build{ puts("block called") }
  
      expect(definition.to_image_attrs.before_build_callback).to be_a(Proc)
    end

    it "accepts before_build as lambda variable" do
      definition = subject.before_build( -> (context_helper, build_dir) { puts("block called") } )
  
      expect(definition.to_image_attrs.before_build_callback).to be_a(Proc)
    end
  end

  context "before_build" do
    it "saves after_build as proc" do
      definition = subject.after_build{ puts("block called") }
  
      expect(definition.to_image_attrs.after_build_callback).to be_a(Proc)
    end

    it "accepts after_build as lambda variable" do
      definition = subject.after_build( -> (context_helper, build_dir) { puts("block called") } )
  
      expect(definition.to_image_attrs.after_build_callback).to be_a(Proc)
    end
  end
end