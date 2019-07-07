module Jira
  class JiraRepository
    def initialize(jira_client, records = {})
      @records = records
      @client = jira_client
    end
  end
end
