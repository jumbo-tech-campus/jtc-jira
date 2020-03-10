class ApplicationController < ActionController::Base
  before_action :reset_cache_repositories
  before_action :set_teams
  before_action :set_departments
  before_action :set_deployment_constraints
  before_action :set_updating_cache

  protected
  def set_week_dates
    date = DateTime.new(2019, 1, 4)
    @dates = [date]

    loop do
      date = date + 2.weeks
      break if date > DateTime.now

      @dates << date
    end
    @selected_date = params[:date]&.to_datetime || @dates.last
  end

  def set_dates
    @end_date = ApplicationHelper.safe_parse(params[:end_date]) || Date.today
    @start_date = ApplicationHelper.safe_parse(params[:start_date]) || Date.today - 2.months
  end

  def set_year_dates
    @end_date = ApplicationHelper.safe_parse(params[:end_date]) || DateTime.new(Date.today.year,12,31)
    @start_date = ApplicationHelper.safe_parse(params[:start_date]) || DateTime.new(Date.today.year,1,1)
  end

  def to_csv(table)
    ::CSV.generate(headers: true) do |csv|
      table.each do |row|
        csv << row
      end
    end
  end

  private
  def set_teams
    @teams = Repository.for(:team).all.sort_by(&:name)
    @scrum_teams = @teams.select{ |team| team.is_scrum_team? }
  end

  def set_departments
    @departments = Repository.for(:department).all
  end

  def set_deployment_constraints
    @deployment_constraints = Repository.for(:deployment_constraint).all.
      sort_by(&:name).delete_if{ |deployment_constraint| deployment_constraint.id == 5 }
  end

  def set_updating_cache
    @updating_cache_since = ApplicationHelper.safe_parse(Cache::RedisClient.new().get('updating_cache_since'))
  end

  def reset_cache_repositories
    CacheService.register_repositories
  end
end
