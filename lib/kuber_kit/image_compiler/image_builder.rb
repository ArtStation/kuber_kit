class KuberKit::ImageCompiler::ImageBuilder
  include KuberKit::Import[
    "shell.docker_commands",
    "image_compiler.version_tag_builder"
  ]

  Contract KuberKit::Shell::AbstractShell, KuberKit::Core::Image, String, KeywordArgs[
    context_helper: Maybe[KuberKit::Core::ContextHelper::AbstractHelper]
  ] => Any
  def build(shell, image, build_dir, context_helper: nil)
    image.before_build_callback.call(context_helper, build_dir) if image.before_build_callback

    build_options = ["-t=#{image.registry_url}"]
    # use quite option for api mode ui, so it will only return built image id
    if KuberKit.ui_mode == :api
      build_options << "-q"
    end

    build_result = docker_commands.build(shell, build_dir, build_options)

    if image.registry.remote?
      docker_commands.tag(shell, image.registry_url, image.remote_registry_url)
      docker_commands.push(shell, image.remote_registry_url)
    end

    image.after_build_callback.call(context_helper, build_dir) if image.after_build_callback

    build_result
  end
end