class KanbanSprint < Sprint
  def issues
    @issues ||= team.issues.select do |issue|
      issue.release_date&.between?(start_date, end_date.end_of_day)
    end
  end

  def closed?
    end_date.end_of_day < DateTime.now
  end

  def open?
    DateTime.now.between?(start_date.beginning_of_day, end_date.end_of_day)
  end

  def id
    "#{end_date.year}_#{start_date.cweek}"
  end
end
