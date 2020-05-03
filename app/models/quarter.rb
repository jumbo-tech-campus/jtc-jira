class Quarter < ActiveModelSerializers::Model
  attr_reader :id, :start_week, :end_week, :fix_version, :year

  def initialize(id, start_week, end_week, fix_version, year)
    @id, @start_week, @end_week, @fix_version, @year = id, start_week, end_week, fix_version, year
  end

  def name
    fix_version.chomp(' plan')
  end

  def start_date
    DateTime.commercial(year, start_week, 1)
  end

  def end_date
    DateTime.commercial(year, end_week, 7).end_of_day
  end

  def number_of_days
    (end_date -  start_date).to_f
  end

  def days_since_start(date)
    return 0 unless date.between?(start_date, end_date)

    (date - start_date).to_f
  end

  def portion_passed
    return 1 if DateTime.now > end_date

    (days_since_start(DateTime.now) / number_of_days)
  end

  def ==(quarter)
    self.id == quarter.id
  end
end
