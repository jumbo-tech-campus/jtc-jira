require 'jira-ruby'

class JiraClient
  extend Forwardable

  def initialize
    options = {
      :username     => ENV['JIRA_USERNAME'],
      :password     => ENV['JIRA_API_KEY'],
      :site         => ENV['JIRA_SITE'],
      :context_path => '',
      :auth_type    => :basic
    }

    @client = JIRA::Client.new(options)
  end

  def_delegators :@client, :Board, :Agile, :Issue, :Sprint
end
