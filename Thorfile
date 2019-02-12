require 'dotenv/load'
require_relative 'config/environment.rb'

class Cache < Thor
  desc "cache data", "Extract boards from JIRA and store in Redis cache"
  def all
    # first make sure we use the Jira repositories to fetch data
    JiraService.new.register_jira_repositories

    teams = Repository.for(:team).all
    boards = teams.map{ |team| Repository.for(:board).find(team.board_id)}

    redis_client = ::Cache::RedisClient.new
    puts "Redis keys #{redis_client.keys}"
    puts "Caching #{teams.size} teams"
    ::Cache::TeamRepository.new(redis_client).save(teams)
    $stdout.flush
    board_repo = ::Cache::BoardRepository.new(redis_client)
    sprint_repo = ::Cache::SprintRepository.new(redis_client)

    boards.each do |board|
      puts "Cache board #{board.id} for team #{board.team.name}"
      board_repo.save(board)
      $stdout.flush
      board.recent_sprints(6).each do |sprint|
        puts "Caching sprint #{sprint.name}"
        sprint_repo.save(sprint)
        $stdout.flush
      end
    end
  end
end
