class TestSshShell < KuberKit::Shell::SshShell
  def exec!(command, merge_stderr: false)
    return ""
  end

  def recursive_list_files(path)
    return []
  end
end