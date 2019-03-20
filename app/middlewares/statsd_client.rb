require 'datadog/statsd'

class StatsdClient
  extend Forwardable

  def initialize
    @client = Datadog::Statsd.new(
      ENV['STATSD_HOST'],
      ENV['STATSD_PORT'] || 8125,
      {
        namespace: 'jtc_jira',
        tags: [],
        logger: Rails.logger
      }
    )
  end

  def_delegators :@client, :timing
end
