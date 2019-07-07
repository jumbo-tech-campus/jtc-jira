class Quarter < ActiveModelSerializers::Model
  attr_reader :start_week, :end_week, :fix_version

  def initialize(start_week, end_week, fix_version)
    @start_week, @end_week, @fix_version = start_week, end_week, fix_version
  end

  def name
    fix_version.chomp(' plan')
  end
end
