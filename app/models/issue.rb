class Issue < ActiveModelSerializers::Model
  attr_reader :key, :summary, :id, :estimation, :created,  :status,
    :state_changed_events, :in_progress_date
  attr_accessor :epic, :assignee, :resolution

  RELEASED_STATES = ['Done', 'Released']
  PENDING_RELEASE_STATES = ['Ready for prod', 'Pending release']
  IN_PROGRESS_STATES = ['In Progress', 'Development', 'Specification']

  def initialize(key, summary, id, estimation, created, status, resolution_date, in_progress_date, release_date, pending_release_date, done_date)
    @key, @summary, @id, @estimation, @created, @status  = key, summary, id, estimation, created, status
    @resolution_date, @in_progress_date, @release_date, @pending_release_date, @done_date = resolution_date, in_progress_date, release_date, pending_release_date, done_date
    @state_changed_events = []
  end

  def jira_url
    URI.join(ENV['JIRA_SITE'], "browse/", key)
  end

  def in_progress_date
    @in_progress_date ||= @state_changed_events.find{ |event| IN_PROGRESS_STATES.include?(event.to_state) }&.created
  end

  def release_date
    return nil unless RELEASED_STATES.include?(status)
    return done_date if done_date

    @release_date ||= @state_changed_events.reverse.find{ |event| RELEASED_STATES.include?(event.to_state) }&.created
  end

  def done_date
    return nil unless RELEASED_STATES.include?(status)

    @done_date || @state_changed_events.reverse.find{ |event| event.to_state == 'Done' }&.created
  end

  def pending_release_date
    return nil unless PENDING_RELEASE_STATES.include?(status) || RELEASED_STATES.include?(status)

    @pending_release_date ||= @state_changed_events.reverse.find{ |event| PENDING_RELEASE_STATES.include?(event.to_state) }&.created
  end

  def resolution_date
    return pending_release_date if pending_release_date.present?
    return release_date if release_date.present?
    return @resolution_date
  end

  def cycle_time
    return nil unless released? && in_progress_date.present?

    (release_date - in_progress_date).to_f
  end

  def short_cycle_time
    return nil unless pending_release_date.present? && in_progress_date.present? && resolution == 'Done'

    (pending_release_date - in_progress_date).to_f
  end

  def cycle_time_delta
    return nil unless released?
    return 0 unless pending_release_date.present?

    (release_date - pending_release_date).to_f
  end

  def closed?
    resolution_date.present?
  end

  def released?
    release_date.present? && resolution == 'Done'
  end

  def pending_release?
    return false if released?

    pending_release_date.present? && resolution == 'Done'
  end

  def resolution_time
    return nil unless closed?

    (resolution_date - created).to_f
  end

  def parent_epic
    epic&.parent_epic
  end

  def ==(issue)
    self.id == issue.id
  end
end
