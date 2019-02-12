class Issue < ActiveModelSerializers::Model
  attr_reader :key, :summary, :id, :estimation, :created, :resolution_date
  attr_accessor :epic

  def initialize(key, summary, id, estimation, created, resolution_date)
    @key, @summary, @id, @estimation, @created, @resolution_date = key, summary, id, estimation, created, resolution_date
  end

  def jira_url
    URI.join(ENV['JIRA_SITE'], "browse/", key)
  end

  def to_s
    "Issue: #{key} #{summary}, estimation: #{estimation}, epic: #{epic&.name}"
  end
end
