class DowntimeEvent
  attr_reader :alert_down, :alert_up

  def initialize(alert_down, alert_up)
    @alert_down, @alert_up = alert_down, alert_up
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
    if alert_up.present? && downtime_event.alert_up.present?
      downtime_event.ended_at >= started_at && ended_at >= downtime_event.started_at
    else
      downtime_event.started_at >= started_at
    end
  end

  def overlapping_events_from(downtime_events)
    downtime_events.select{ |event| self.overlaps_with?(event) }
  end
end
