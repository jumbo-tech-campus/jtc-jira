class Period
  attr_reader :start_date, :duration

  def initialize(start_date, duration)
    @start_date, @duration = start_date, duration
  end

  def end_date
    @start_date + @duration
  end

  def name
    if duration == 2.weeks
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
    periods = [Period.new(start_date, interval)]

    loop do
      start_date = start_date + interval
      periods << Period.new(start_date, interval)

      break if start_date > end_date
    end

    periods
  end
end
