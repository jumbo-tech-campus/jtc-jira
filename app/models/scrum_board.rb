class ScrumBoard < Board
  def open_sprint
    sprints.select{ |sprint| !sprint.closed? }.first
  end

  def recent_closed_sprints(n)
    closed_sprints.sort_by(&:end_date).reverse.take(n)
  end

  def recent_sprints(n)
    sprints.sort_by(&:end_date).reverse.take(n)
  end

  def sprints_from(year)
    sprints.select{ |sprint| sprint.end_date > DateTime.new(year, 1, 1) }.sort_by(&:end_date)
  end

  def last_closed_sprint
    recent_closed_sprints(1).first
  end

  def sprints_for(date)
    (sprints.select { |sprint| is_date_between?(date, sprint.start_date, sprint.end_date) } +
      sprints.select { |sprint| is_date_between?(date, sprint.start_date, sprint.complete_date)}).uniq
  end

  def is_date_between?(date, start_date, end_date)
    return false if start_date.nil? || end_date.nil?

    date.between?(start_date, end_date)
  end

  def issues
    @issues ||= sprints.inject([]) do |memo, sprint|
      sprint.issues.each do |issue|
        memo << issue unless memo.include?(issue)
      end
      memo
    end
  end
end
