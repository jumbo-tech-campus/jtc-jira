Dir[File.join(__dir__, 'repositories', '*.rb')].each { |file| require file }

Repository.register(:board, BoardRepository.new)
Repository.register(:sprint, SprintRepository.new)
Repository.register(:issue, IssueRepository.new)
Repository.register(:epic, EpicRepository.new)
