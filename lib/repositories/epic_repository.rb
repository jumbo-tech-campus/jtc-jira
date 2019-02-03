require_relative '../models/epic'
require_relative 'repository'

class EpicRepository
  def initialize
    @records = {}
    @client = JiraClient.new
  end

  def find(key)
    @records[key] ||= Epic.from_issue(@client.Issue.find(key))
  end
end
