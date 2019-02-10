module Jira
  class JiraRepository
    def initialize(jira_client)
      @records = {}
      @client = jira_client
    end
  end
end
