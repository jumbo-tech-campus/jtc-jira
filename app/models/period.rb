class Period
  attr_reader :start_date, :duration

  def initialize(start_date, duration)
    @start_date, @duration = start_date, duration
  end

  def end_date
    @start_date + @duration
  end

  def duration_in_days
    @duration / 86400.0
  end

  def name
    if duration == 1.week
      "Week #{start_date.cweek}"
    elsif duration == 2.weeks
      "Week #{start_date.cweek} & #{start_date.cweek + 1}"
    elsif duration == 4.weeks
      "Week #{start_date.cweek} - #{start_date.cweek + 3}"
    elsif duration == 1.month
      "Week #{start_date.strftime("%B")}"
    elsif duration == 1.year
      start_date.strftime("%Y")
    end
  end

  def self.create_periods(start_date, end_date, interval)
    periods = []

    while start_date < end_date
      periods << Period.new(start_date, interval)
      start_date = start_date + interval
    end

    periods
  end
end
