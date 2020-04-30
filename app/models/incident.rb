class Incident < Issue
  attr_accessor :start_date, :end_date, :reported_date, :causes

  def initialize(*args)
    super
    @causes = []
  end

  def time_to_detect
    puts reported_date.inspect
    return nil unless valid?

    (reported_date - start_date).to_f
  end

  def time_to_recover
    return nil unless valid?

    (end_date - start_date).to_f
  end

  def time_to_repair
    return nil unless valid?

    (end_date - reported_date).to_f
  end

  def valid?
    start_date.present? && end_date.present? && reported_date.present?
  end

  def class_name
    'Incident'
  end
end
