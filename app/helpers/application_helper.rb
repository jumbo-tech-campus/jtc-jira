module ApplicationHelper
  def self.safe_parse(value, default = nil)
    DateTime.parse(value.to_s)
  rescue ArgumentError
    default
  end

  def self.safe_parse_epoch(value, default = nil)
    sec = (value / 1000).to_s
    DateTime.strptime(sec, '%s').in_time_zone()
  rescue ArgumentError, NoMethodError
    default
  end

  def self.format_to_days_hours_and_minutes(date_time_difference)
    return '' unless date_time_difference
    days = date_time_difference.floor
    hours = ((date_time_difference  - days) * 24).floor
    minutes = (((date_time_difference  - days) * 24) - hours) * 60

    if hours == 0
      "#{minutes.round}m"
    elsif days == 0
      "#{hours}h #{minutes.round}m"
    else
      "#{days}d #{hours}h #{minutes.round}m"
    end
  end
end
