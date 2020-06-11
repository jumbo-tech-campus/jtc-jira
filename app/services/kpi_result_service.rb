class KpiResultService
  def self.recalculate_kpi_results
    repository = Repository.for(:kpi_goal)
    repository.all.each do |kpi_goal|
      kpi_goal.calculate_kpi_result
      repository.save(kpi_goal)
    end
  end
end
