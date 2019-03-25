class DeploymentProject < Project
  attr_reader :issues

  def initialize(*args)
    super
    @issues = []
  end

  def sorted_issues
    issues.sort_by(&:created)
  end
end
