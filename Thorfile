require 'dotenv/load'
require_relative 'config/environment.rb'

class Cache < Thor
  desc 'cache data', 'Extract boards from JIRA and store in Redis cache'
  def all
    statsd_client = StatsdClient.new
    started = Time.now
    statsd_client.increment('thor.cache_started')

    # first make sure we use the Jira repositories to fetch data
    JiraService.register_repositories
    ConfigService.register_repositories
    begin
      teams = Repository.for(:team).all
      puts "Retrieved #{teams.size} teams"
    rescue JIRA::HTTPError => e
      puts "JIRA username: #{ENV['JIRA_USERNAME']}"
      puts "JIRA API key: #{ENV['JIRA_API_KEY']}"
      puts "JIRA HTTP error:\n#{e.message}\nResponse from JIRA:\n#{e.response.inspect}"
    end
    $stdout.flush

    boards = []
    failed_teams = []
    teams.each do |team|
      begin
        puts "Retrieving board #{team.board_id} for team #{team.name}"
        board = Repository.for(:board).find_by(team: team)
        if board.nil?
          puts "Board #{team.board_id} for team #{team.name} nil - not found. "
          failed_teams << team
        elsif !boards.include?(board)
          boards << board
        end
      rescue StandardError => e
        puts "Board #{team.board_id} for team #{team.name} exception #{e} - not found. "
        failed_teams << team
      end
      $stdout.flush
    end

    puts "Removing #{failed_teams.size} teams from teams set and continuing."
    teams -= failed_teams
    puts "Retrieved #{boards.size} boards for the teams"
    $stdout.flush

    quarters = Repository.for(:quarter).all
    puts "Retrieved #{quarters.size} quarters"
    $stdout.flush

    parent_epics = Repository.for(:parent_epic).all
    puts "Retrieved #{parent_epics.size} parent_epics"
    $stdout.flush

    Rails.cache.clear

    redis_client = ::Cache::RedisClient.new
    redis_client.set('updating_cache_since', started.strftime('%Y-%m-%d %H:%M'))

    puts "Caching #{teams.size} teams"
    team_repo = ::Cache::TeamRepository.new(redis_client)
    sprint_repo = ::Cache::SprintRepository.new(redis_client)
    teams.each do |team|
      team_repo.save(team)
    end
    $stdout.flush

    puts "Caching #{quarters.size} quarters"
    ::Cache::QuarterRepository.new(redis_client).save(quarters)
    $stdout.flush

    puts "Caching #{parent_epics.size} parent_epics"
    ::Cache::ParentEpicRepository.new(redis_client).save(parent_epics)
    $stdout.flush

    board_repo = ::Cache::BoardRepository.new(redis_client)
    boards.each do |board|
      puts "Cache board #{board.id}"
      board_repo.save(board)

      next unless board.is_a? ScrumBoard

      board.sprints_from(2019).each do |sprint|
        puts "Caching sprint #{sprint.name} (#{sprint.id})"
        sprint_repo.save(sprint)
        $stdout.flush
      end
    end

    CacheService.register_repositories

    puts "Recalculating #{Repository.for(:kpi_goal).all.size} KPI results"
    KpiResultService.recalculte_kpi_results

    Rails.cache.clear
    redis_client.del('updating_cache_since')

    puts 'Rails cache cleared. Caching job finished!'

    statsd_client.timing('thor.cache_duration', (Time.now - started) * 1000)
  end
end
