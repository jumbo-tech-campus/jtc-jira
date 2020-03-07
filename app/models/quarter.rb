class Quarter < ActiveModelSerializers::Model
  attr_reader :start_week, :end_week, :fix_version, :year

  def initialize(start_week, end_week, fix_version, year)
    @start_week, @end_week, @fix_version, @year = start_week, end_week, fix_version, year
  end

  def name
    fix_version.chomp(' plan')
  end

  def start_date
    Date.commercial(year, start_week, 1)
  end

  def end_date
    Date.commercial(year, end_week, 7)
  end
end
