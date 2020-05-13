class DowntimeEvent
  attr_reader :alert_down, :alert_up, :overlapping_events

  def initialize(alert_down, alert_up)
    @alert_down, @alert_up = alert_down, alert_up
    @overlapping_events = []
  end

  def duration
    return nil unless alert_up

    (ended_at - started_at).to_f
  end

  def started_at
    alert_down.alerted_at
  end

  def ended_at
    alert_up&.alerted_at
  end

  def summary
    alert_down.summary
  end

  def overlaps_with?(downtime_event)
    if alert_up
      downtime_event.ended_at >= started_at && ended_at >= downtime_event.started_at
    else
      downtime_event.started_at >= started_at
    end
  end
end
