class Quarter < ActiveModelSerializers::Model
  attr_reader :start_week, :end_week, :fix_version, :year

  def initialize(start_week, end_week, fix_version, year)
    @start_week, @end_week, @fix_version, @year = start_week, end_week, fix_version, year
  end

  def name
    fix_version.chomp(' plan')
  end
end
