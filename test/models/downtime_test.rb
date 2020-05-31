# frozen_string_literal: true

require 'test_helper'

class DowntimeTest < ActiveSupport::TestCase
  setup do
    @event = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 55)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 10)))
    @dt = Downtime.new(@event)
  end

  test 'downtime object can be created' do
    assert @dt.present?
  end

  test 'overlapping event is added' do
    overlapping_event = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 0o0)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 10)))
    events = @dt.overlapping_events_from([overlapping_event])
    assert_includes(events, overlapping_event)
  end

  test 'both overlapping event are added' do
    overlapping_event1 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 0o0)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 10)))
    overlapping_event2 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 0o3)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 10)))
    events = @dt.overlapping_events_from([overlapping_event1, overlapping_event2])
    assert_includes(events, overlapping_event1)
    assert_includes(events, overlapping_event2)
    assert_equal(events.size, 2)
  end

  test 'overlapping event end is added' do
    overlapping_event1 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 0o0)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 10)))
    overlapping_event2 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 0o3)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 10)))
    overlapping_event_end = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 10)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 14)))
    events = @dt.overlapping_events_from([overlapping_event1, overlapping_event2, overlapping_event_end])
    assert_includes(events, overlapping_event_end)
    assert_equal(events.size, 3)
  end

  test 'overlapping event start is added' do
    overlapping_event1 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 0o0)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 10)))
    overlapping_event2 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 0o3)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 10)))
    overlapping_event_start = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 50)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 55)))
    events = @dt.overlapping_events_from([overlapping_event1, overlapping_event2, overlapping_event_start])
    assert_includes(events, overlapping_event_start)
    assert_equal(events.size, 3)
  end

  test 'not overlapping event end is not added' do
    overlapping_event1 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 0o0)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 10)))
    overlapping_event2 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 0o3)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 10)))
    not_overlapping_event_end = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 11)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 14)))
    events = @dt.overlapping_events_from([overlapping_event1, overlapping_event2, not_overlapping_event_end])
    assert_not_includes(events, not_overlapping_event_end)
    assert_equal(events.size, 2)
  end

  test 'event overlapping other event is added' do
    overlapping_event1 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 0o0)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 15)))
    overlapping_event2 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 12)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 20)))
    events = @dt.overlapping_events_from([overlapping_event1, overlapping_event2])
    assert_includes(events, overlapping_event1)
    assert_includes(events, overlapping_event2)
    assert_equal(events.size, 2)
  end

  test 'event double overlapping other event is added' do
    overlapping_event1 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 0o0)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 15)))
    overlapping_event2 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 12)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 20)))
    overlapping_event3 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 19)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 25)))
    events = @dt.overlapping_events_from([overlapping_event1, overlapping_event2, overlapping_event3])
    assert_includes(events, overlapping_event1)
    assert_includes(events, overlapping_event2)
    assert_includes(events, overlapping_event3)
    assert_equal(events.size, 3)
  end

  test 'event triple overlapping other event is added' do
    overlapping_event1 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 45)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 8)))
    overlapping_event2 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 40)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 45)))
    overlapping_event3 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 20)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 42)))
    overlapping_event4 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 24)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 26)))
    events = @dt.overlapping_events_from([overlapping_event1, overlapping_event2, overlapping_event3, overlapping_event4])
    assert_includes(events, overlapping_event1)
    assert_includes(events, overlapping_event2)
    assert_includes(events, overlapping_event3)
    assert_includes(events, overlapping_event4)
    assert_equal(events.size, 4)
  end

  test 'event triple overlapping but non overlapping event is not added' do
    overlapping_event1 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 45)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 8, 8)))
    overlapping_event2 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 40)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 45)))
    overlapping_event3 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 20)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 42)))
    overlapping_event4 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 24)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 26)))
    overlapping_event5 = DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 15)), OpenStruct.new(alerted_at: DateTime.new(2019, 1, 1, 7, 18)))
    events = @dt.overlapping_events_from([overlapping_event1, overlapping_event2, overlapping_event3, overlapping_event4, overlapping_event5])
    assert_not_includes(events, overlapping_event5)
    assert_equal(events.size, 4)
  end

  test 'creates 1 downtime object from 9 overlapping events' do
    overlapping_events = [DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 17, 55)), OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 0o0)))]
    overlapping_events << DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 17, 55)), OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 0o5)))
    overlapping_events << DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 0o0)), OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 0o5)))
    overlapping_events << DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 0o7)), OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 25)))
    overlapping_events << DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 20)), OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 25)))
    overlapping_events << DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 15)), OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 25)))
    overlapping_events << DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 10)), OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 30)))
    overlapping_events << DowntimeEvent.new(OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 0o0)), OpenStruct.new(alerted_at: DateTime.new(2020, 5, 13, 18, 30)))

    dts = Downtime.create_from(overlapping_events)

    assert_equal(1, dts.size)
    assert_equal(DateTime.new(2020, 5, 13, 17, 55), dts.first.started_at)
    assert_equal(DateTime.new(2020, 5, 13, 18, 30), dts.first.ended_at)
  end

  test 'calculate duration outside of maintenance window on one day' do
    events = [DowntimeEvent.new(OpenStruct.new(alerted_at: Time.zone.local(2020, 5, 12, 8, 5).to_datetime), OpenStruct.new(alerted_at: Time.zone.local(2020, 5, 12, 9, 55).to_datetime))]

    downtime = Downtime.create_from(events).first
    assert_equal(0.0763888888888889, downtime.duration_excluding_maintenance)
  end

  test 'calculate duration started during maintenance window on one day' do
    events = [DowntimeEvent.new(OpenStruct.new(alerted_at: Time.zone.local(2020, 5, 13, 7, 55).to_datetime), OpenStruct.new(alerted_at: Time.zone.local(2020, 5, 13, 8, 10).to_datetime))]

    downtime = Downtime.create_from(events).first
    assert_equal(0.006944444444444444, downtime.duration_excluding_maintenance)
  end

  test 'calculate duration completely inside maintenance window on one day' do
    events = [DowntimeEvent.new(OpenStruct.new(alerted_at: Time.zone.local(2020, 5, 13, 0o0, 0o0).to_datetime), OpenStruct.new(alerted_at: Time.zone.local(2020, 5, 13, 7, 10).to_datetime))]

    downtime = Downtime.create_from(events).first
    assert_equal(0, downtime.duration_excluding_maintenance)
  end

  test 'calculate full day outage' do
    events = [DowntimeEvent.new(OpenStruct.new(alerted_at: Time.zone.local(2020, 5, 13, 0o0, 0o0).to_datetime), OpenStruct.new(alerted_at: Time.zone.local(2020, 5, 14, 0o0, 0o0).to_datetime))]

    downtime = Downtime.create_from(events).first
    assert_equal(0.6666666666666666, downtime.duration_excluding_maintenance)
  end

  test 'calculate outage across 2 maintenance windows' do
    events = [DowntimeEvent.new(OpenStruct.new(alerted_at: Time.zone.local(2020, 5, 13, 0o0, 0o0).to_datetime), OpenStruct.new(alerted_at: Time.zone.local(2020, 5, 14, 6, 0o0).to_datetime))]

    downtime = Downtime.create_from(events).first
    assert_equal(0.6666666666666666, downtime.duration_excluding_maintenance)
  end

  test 'calculate outage across multiple maintenance windows' do
    events = [DowntimeEvent.new(OpenStruct.new(alerted_at: Time.zone.local(2020, 5, 13, 0o0, 0o0).to_datetime), OpenStruct.new(alerted_at: Time.zone.local(2020, 5, 16, 16, 0o0).to_datetime))]

    downtime = Downtime.create_from(events).first
    assert_equal(2.3333333333333335, downtime.duration_excluding_maintenance)
  end
end
