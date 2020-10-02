require 'cli/ui'

class Indocker::UI
  class TaskGroup < CLI::UI::SpinGroup
  end

  def init
    ::CLI::UI::StdoutRouter.enable
  end

  def create_task_group
    TaskGroup.new
  end

  def create_task(title, &block)
    CLI::UI::Spinner.spin(title, &block)
  end
end