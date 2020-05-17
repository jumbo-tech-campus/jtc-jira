class Alert < Issue
  attr_accessor :event_key, :alerted_at

  def initialize(*args)
    super
  end

  def class_name
    'Alert'
  end

  def is_down_alert?
    summary.include?('[Triggered]')
  end
end
