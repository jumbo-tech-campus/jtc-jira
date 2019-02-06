client = JiraClient.new
Repository.register(:board, BoardRepository.new(client))
Repository.register(:sprint, SprintRepository.new(client))
Repository.register(:issue, IssueRepository.new(client))
Repository.register(:epic, EpicRepository.new(client))
