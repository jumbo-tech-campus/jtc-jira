class KanbanSprint < Sprint
  def issues
    @issues ||= board.issues.select do |issue|
      issue.release_date&.between?(start_date, end_date.end_of_day)
    end
  end

  def id
    "#{end_date.year}_#{start_date.cweek}"
  end
end
