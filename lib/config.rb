Dir[File.join(__dir__, 'repositories', '*.rb')].each { |file| require file }

class Config
  attr_reader :subteam_name

  def initialize(subteam_name)
    @subteam_name = subteam_name
  end

  def filter_subteam?
    !@subteam_name.to_s.empty?
  end

  def init_repositories
    client = JiraClient.new
    Repository.register(:board, BoardRepository.new(client))
    Repository.register(:sprint, SprintRepository.new(client))
    Repository.register(:issue, IssueRepository.new(client, self))
    Repository.register(:epic, EpicRepository.new(client))
  end
end
