class TestShell < KuberKit::Shell::LocalShell
  def exec!(command)
    return ""
  end

  def recursive_list_files(path)
    return []
  end
end