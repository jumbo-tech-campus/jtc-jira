require 'dotenv/load'
require_relative 'config/environment.rb'

class Cache < Thor
  desc "cache data", "Extract boards from JIRA and store in Redis cache"
  def all
    statsd_client = StatsdClient.new
    started = Time.now

    # first make sure we use the Jira repositories to fetch data
    JiraService.register_repositories
    ConfigService.register_repositories

    teams = Repository.for(:team).all
    puts "Retrieved #{teams.size} teams"

    projects = Repository.for(:project).all
    puts "Retrieved #{projects.size} projects"
    $stdout.flush
    quarters = Repository.for(:quarter).all
    puts "Retrieved #{quarters.size} quarters"
    $stdout.flush
    issue_collections = Repository.for(:issue_collection).all
    puts "Retrieved #{issue_collections.size} issue collections"
    $stdout.flush
    # for the parent epic reporting we need to cache all epics per parent epic
    ParentEpicService.new.associate_epics_to_parent_epic
    puts "Retrieved all epics for parent_epics"
    $stdout.flush
    boards = teams.map do |team|
      begin
        Repository.for(:board).find(team.board_id)
      rescue
        puts "Board #{team.board_id} for team #{team.name} not found. Removing team from teams set and continuing."
        teams.delete(team)
        nil
      end
    end

    redis_client = ::Cache::RedisClient.new
    redis_client.flushall

    puts "Redis database flushed - database size is now #{redis_client.dbsize}"
    puts "Caching #{teams.size} teams"
    ::Cache::TeamRepository.new(redis_client).save(teams)
    $stdout.flush
    puts "Caching #{projects.size} projects"
    ::Cache::ProjectRepository.new(redis_client).save(projects)
    $stdout.flush
    puts "Caching #{quarters.size} quarters"
    ::Cache::QuarterRepository.new(redis_client).save(quarters)
    $stdout.flush
    puts "Caching #{issue_collections.size} issue collections"
    issue_collection_repo = ::Cache::IssueCollectionRepository.new(redis_client)
    issue_collections.each{ |issue_collection| issue_collection_repo.save(issue_collection) }
    $stdout.flush
    board_repo = ::Cache::BoardRepository.new(redis_client)
    sprint_repo = ::Cache::SprintRepository.new(redis_client)

    boards.each do |board|
      next if board.nil?

      puts "Cache board #{board.id} for team #{board.team.name}"
      board_repo.save(board)
      $stdout.flush
      board.sprints_from(2019).each do |sprint|
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
