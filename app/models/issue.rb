class Issue < ActiveModelSerializers::Model
  attr_reader :key, :summary, :id, :estimation, :created,  :status, :resolution_date,
    :state_changed_events, :in_progress_date, :done_date, :ready_for_prod_date
  attr_accessor :epic, :assignee

  def initialize(key, summary, id, estimation, created, status, resolution_date, in_progress_date, done_date, ready_for_prod_date)
    @key, @summary, @id, @estimation, @created, @status  = key, summary, id, estimation, created, status
    @resolution_date, @in_progress_date, @done_date, @ready_for_prod_date = resolution_date, in_progress_date, done_date, ready_for_prod_date
    @state_changed_events = []
  end

  def jira_url
    URI.join(ENV['JIRA_SITE'], "browse/", key)
  end

  def in_progress_date
    @in_progress_date ||= @state_changed_events.find{ |event| event.to_state == "In Progress" }&.created
  end

  def done_date
    return nil if status != 'Done'

    @done_date ||= @state_changed_events.reverse.find{ |event| event.to_state == "Done" }&.created
  end

  def ready_for_prod_date
    return nil if status != 'Done' && status != "Ready for prod"

    @ready_for_prod_date ||= @state_changed_events.reverse.find{ |event| event.to_state == "Ready for prod" }&.created
  end

  def cycle_time
    return nil unless done_date && in_progress_date

    (done_date - in_progress_date).to_f
  end

  def short_cycle_time
    return nil unless ready_for_prod_date && in_progress_date

    (ready_for_prod_date - in_progress_date).to_f
  end

  def cycle_time_delta
    return nil unless done_date
    return 0 unless ready_for_prod_date

    (done_date - ready_for_prod_date).to_f
  end

  def closed?
    resolution_date.present?
  end

  def resolution_time
    return nil unless closed?

    (resolution_date - created).to_f
  end

  def ==(issue)
    self.id == issue.id
  end
end
