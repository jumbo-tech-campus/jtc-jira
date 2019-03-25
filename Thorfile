require 'dotenv/load'
require_relative 'config/environment.rb'

class Cache < Thor
  desc "cache data", "Extract boards from JIRA and store in Redis cache"
  def all
    statsd_client = StatsdClient.new
    started = Time.now

    # first make sure we use the Jira repositories to fetch data
    JiraService.new.register_jira_repositories

    teams = Repository.for(:team).all
    projects = Repository.for(:project).all
    boards = teams.map{ |team| Repository.for(:board).find(team.board_id)}

    redis_client = ::Cache::RedisClient.new
    puts "Caching #{teams.size} teams"
    ::Cache::TeamRepository.new(redis_client).save(teams)
    $stdout.flush
    puts "Caching #{projects.size} projects"
    ::Cache::ProjectRepository.new(redis_client).save(projects)
    $stdout.flush
    board_repo = ::Cache::BoardRepository.new(redis_client)
    sprint_repo = ::Cache::SprintRepository.new(redis_client)
    number_of_cached_sprints = YAML.load_file(Rails.root.join('config.yml'))[:number_of_cached_sprints]

    boards.each do |board|
      puts "Cache board #{board.id} for team #{board.team.name}"
      board_repo.save(board)
      $stdout.flush
      board.recent_sprints(number_of_cached_sprints).each do |sprint|
        puts "Caching sprint #{sprint.name}"
        sprint_repo.save(sprint)
        $stdout.flush
      end if board.is_a? ScrumBoard
    end

    statsd_client.timing('thor.cache',
      (Time.now - started) * 1000,
      tags: ["action:all"]
    )
  end
end
