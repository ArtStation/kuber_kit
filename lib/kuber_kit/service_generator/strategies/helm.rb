class KuberKit::ServiceGenerator::Strategies::Helm < KuberKit::ServiceGenerator::Strategies::Abstract
  include KuberKit::Import[
    "service_reader.reader",
    "shell.bash_commands",
    "configs",
  ]

  Contract KuberKit::Shell::AbstractShell, KuberKit::Core::Service, String => Any
  def generate(shell, service, export_path)
    service_config        = reader.read(shell, service)
    chart_root_path       = File.join(export_path, "#{service.name}_chart")
    chart_templates_path  = File.join(chart_root_path, "templates")
    chart_config_path     = File.join(chart_root_path, "Chart.yaml")
    release_path          = File.join(chart_templates_path, "release.yaml")

    bash_commands.mkdir_p(shell, chart_root_path)
    bash_commands.mkdir_p(shell, chart_templates_path)

    shell.write(release_path, service_config)
    shell.write(chart_config_path, chart_config_content(service.uri))
  end

  def chart_config_content(release_name)
    query = <<-CHART
apiVersion: v2
name: #{release_name}
description: #{release_name}
type: application
version: 1.0.0
appVersion: "1.0.0"
    CHART
  end
end