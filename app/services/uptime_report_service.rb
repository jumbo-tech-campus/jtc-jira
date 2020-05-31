class UptimeReportService < BaseIssuesReportService
  def initialize(start_date, end_date)
    @start_date = Date.commercial(start_date.year, start_date.cweek, 1).in_time_zone.to_datetime
    @end_date = Date.commercial(end_date.year, end_date.cweek, 7).in_time_zone.to_datetime.end_of_day
    @periods = Period.create_periods(@start_date, @end_date, 1.week)
  end

  def uptime_report
    {
      table: downtime_events_table,
      downtime_table: downtime_table,
      uptime_table: uptime_table,
      downtime_per_period: downtime_per_period,
      uptime_percentage_per_period: uptime_percentage_per_period,
      uptime_percentage_per_period_excluding_maintenance: uptime_percentage_per_period_excluding_maintenance
    }
  end

  def calculate_kpi_result
    sum = downtimes.sum(&:duration_excluding_maintenance)
    total_days = (@end_date - @start_date).to_f

    uptime = ((total_days - sum) / total_days) * 100

    results = uptime_percentage_per_period_excluding_maintenance.map { |period, uptime| [period.end_date.cweek, uptime] }
    KpiResult.new(uptime, results)
  end

  def downtime_events_table
    table = []
    header = ['Key', 'Title', 'Starts at', 'Ends at', 'Duration']
    table << header
    downtime_events.each do |event|
      table << [
        event.alert_down.key,
        event.summary,
        event.started_at.strftime('%Y-%m-%d %H:%M'),
        event.ended_at&.strftime('%Y-%m-%d %H:%M'),
        ApplicationHelper.format_to_days_hours_and_minutes(event.duration)
      ]
    end

    table
  end

  def downtime_table
    table = []
    header = ['Starts at', 'Ends at', 'Duration', 'Outside of maintenance hours']
    table << header
    downtimes.each do |downtime|
      table << [
        downtime.started_at.strftime('%Y-%m-%d %H:%M'),
        downtime.ended_at.strftime('%Y-%m-%d %H:%M'),
        ApplicationHelper.format_to_days_hours_and_minutes(downtime.duration),
        ApplicationHelper.format_to_days_hours_and_minutes(downtime.duration_excluding_maintenance)
      ]
    end

    table
  end

  def uptime_table
    table = []
    header = ['']
    @periods.each do |period|
      header << period.name
    end
    table << header

    row = ['Uptime']
    uptime_percentage_per_period.each do |_period, uptime|
      row << uptime&.round(1)
    end
    table << row

    row = ['KPI uptime']
    uptime_percentage_per_period_excluding_maintenance.each do |_period, uptime|
      row << uptime&.round(1)
    end
    table << row

    table
  end

  def downtime_events(alerts = nil)
    alerts ||= issues
    alerts_per_event_key = alerts.reverse.each_with_object({}) do |alert, memo|
      if memo[alert.event_key]
        memo[alert.event_key] << alert
      else
        memo[alert.event_key] = [alert]
      end
    end

    alerts_per_event_key.map do |_key, value|
      down_alert = value.first.is_down_alert? ? value.first : value.second
      up_alert = value.first.is_down_alert? ? value.second : value.first
      DowntimeEvent.new(down_alert, up_alert)
    end
  end

  def downtimes
    Downtime.create_from(downtime_events)
  end

  def alerts_per_period
    issues_per_period = {}

    @periods.each do |period|
      issues_per_period[period] = issues.select { |issue| issue.alerted_at.between?(period.start_date, period.end_date) }
    end

    issues_per_period
  end

  def downtime_per_period
    events_per_period = alerts_per_period.map do |period, alerts|
      [period, downtime_events(alerts)]
    end

    # because we are looking at downtime per week,
    # the alert events signalling a down or up event may be outside of week
    # correct this by setting fake events for down or up at week end or week start
    events_per_period.each do |_period, events|
      events.each do |event|
        if event.alert_up.nil?
          event.alert_up = OpenStruct.new(alerted_at: Date.commercial(event.alert_down.year, event.alert_down.cweek, 7).in_time_zone.to_datetime.end_of_day)
        elsif event.alert_down.nil?
          event.alert_down = OpenStruct.new(alerted_at: Date.commercial(event.alert_up.year, event.alert_up.cweek, 1).in_time_zone.to_datetime)
        end
      end
    end

    events_per_period.map do |period, events|
      [period, Downtime.create_from(events)]
    end
  end

  def uptime_percentage_per_period
    downtime_per_period.map do |period, downtimes|
      if period.start_date < DateTime.now
        [period, ((period.duration_in_days - downtimes.sum(&:duration)) / period.duration_in_days) * 100]
      else
        [period, nil]
      end
    end
  end

  def uptime_percentage_per_period_excluding_maintenance
    period_duration_excluding_maintenance = (2 / 3.0) * @periods.first.duration_in_days
    downtime_per_period.map do |period, downtimes|
      if period.start_date < DateTime.now
        [period, ((period_duration_excluding_maintenance - downtimes.sum(&:duration_excluding_maintenance)) / period_duration_excluding_maintenance) * 100]
      else
        [period, nil]
      end
    end
  end

  private

  def retrieve_issues
    ::Jira::IssueRepository.new(::Jira::JiraClient.new).find_by(query: "project = JDUA AND
      created >= #{@start_date.strftime('%Y-%m-%d')} AND
      created < #{(@end_date + 1.day).strftime('%Y-%m-%d')} ORDER BY created ASC, key DESC").select { |issue| issue.labels.include?('www.jumbo.com') }
  end
end
