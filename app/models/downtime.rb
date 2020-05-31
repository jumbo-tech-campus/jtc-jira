class Downtime
  attr_reader :events

  MAINTENANCE_START_HOUR = 0
  MAINTENANCE_END_HOUR = 8

  def initialize(downtime_event)
    @events = [downtime_event]
  end

  def overlapping_events_from(downtime_events)
    overlapping_events = get_overlapping_events_for(events, downtime_events)

    loop do
      events_overlapping_events = get_overlapping_events_for(overlapping_events, downtime_events - overlapping_events)
      break if events_overlapping_events.empty?

      overlapping_events.concat(events_overlapping_events)
      overlapping_events.uniq!
    end

    overlapping_events
  end

  def duration
    (ended_at - started_at).to_f
  end

  def duration_excluding_maintenance
    day = started_at.to_date
    duration = 0.0

    while day <= ended_at.to_date
      maintenance_end = Time.zone.local(day.year, day.month, day.day, MAINTENANCE_END_HOUR, 0, 0).to_datetime
      day_end = Time.zone.local(day.year, day.month, day.day + 1, 0, 0, 0).to_datetime

      start_on_day = if started_at.to_date == day && started_at > maintenance_end
                       started_at
                     else
                       maintenance_end
                     end

      if ended_at.to_date > day
        end_on_day = day_end
      elsif ended_at > maintenance_end
        end_on_day = ended_at
      elsif ended_at <= maintenance_end
        end_on_day = maintenance_end
      end

      duration += (end_on_day - start_on_day).to_f

      day += 1.day
    end

    duration
  end

  def started_at
    events.min_by(&:started_at).started_at
  end

  def ended_at
    events.max do |a, b|
      if a.ended_at.nil? || b.ended_at.nil?
        1
      else
        a.ended_at <=> b.ended_at
      end
    end.ended_at
  end

  def self.create_from(downtime_events)
    downtimes = downtime_events.sort_by(&:started_at).map do |event|
      downtime = Downtime.new(event)
      downtime.events.concat(downtime.overlapping_events_from(downtime_events))
      downtime
    end

    downtimes.uniq { |downtime| [downtime.started_at, downtime.ended_at] }
  end

  private

  def get_overlapping_events_for(events_source, downtime_events)
    events_source.each_with_object([]) do |event, memo|
      memo.concat(event.overlapping_events_from(downtime_events))
    end
  end

  def overlaps_with?(downtime)
    downtime.ended_at >= started_at && ended_at >= downtime.started_at
  end
end
