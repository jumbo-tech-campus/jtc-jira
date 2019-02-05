require 'jira-ruby'

class JiraClient
  extend Forwardable

  def initialize
    options = {
      :username     => ENV['USERNAME'],
      :password     => ENV['API_KEY'],
      :site         => ENV['SITE'],
      :context_path => '',
      :auth_type    => :basic
    }

    @client = JIRA::Client.new(options)
  end

  def_delegators :@client, :Board, :Agile, :Issue, :Sprint
end
