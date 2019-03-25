class DeploymentReportService
  def self.for_project(project)
    table = []
    header = ["Date", "Number of deployments"]
    table << header
    issue_count_per_day(project).each do |key, value|
      table << [key, value]
    end

    table
  end

  def self.linear_regression_for_project(project)
    data = issue_count_per_day(project).map do |key, value|
      { date: Time.parse(key).to_i, deployments: value }
    end
    model = Eps::Regressor.new(data, target: :deployments)

    [prediction(model, project.sorted_issues.first.created), prediction(model, project.sorted_issues.last.created)]
  end

  def self.moving_averages_for_project(project)
    date =  project.sorted_issues.first.created
    end_date = project.sorted_issues.last.created
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), project.cycle_time_moving_average_on(date)]

      date = date + 1.week
      if date >= end_date
        moving_averages << [end_date.strftime('%Y-%m-%d'), project.cycle_time_moving_average_on(end_date)]
        break
      end
    end

    moving_averages
  end

  private
  def self.prediction(model, date)
    [date.strftime('%Y-%m-%d'), model.predict(date: date.to_time.to_i)]
  end

  def self.issue_count_per_day(project)
    project.issues.map.inject({}) do |memo, issue|
      date = issue.created.strftime('%Y-%m-%d')
      if memo[date]
        memo[date] += 1
      else
        memo[date] = 1
      end
      memo
    end
  end
end
