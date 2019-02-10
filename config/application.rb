require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module JtcJira
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.to_prepare do
      config = YAML.load_file(Rails.root.join('config.yml'))
      if config[:use_cached_data]
        redis_client = Cache::RedisClient.new
        Repository.register(:board, Cache::BoardRepository.new(redis_client))
        Repository.register(:sprint, Cache::SprintRepository.new(redis_client))
        Repository.register(:issue, Cache::IssueRepository.new(redis_client))
        Repository.register(:team, Cache::TeamRepository.new(redis_client))
      else
        jira_client = ::Jira::JiraClient.new
        Repository.register(:board, Jira::BoardRepository.new(jira_client))
        Repository.register(:sprint, Jira::SprintRepository.new(jira_client))
        Repository.register(:issue, Jira::IssueRepository.new(jira_client))
        Repository.register(:epic, Jira::EpicRepository.new(jira_client))
        Repository.register(:project, Jira::ProjectRepository.new(jira_client))
        Repository.register(:team, Jira::TeamRepository.new(jira_client))
      end

      Factory.register(:board, BoardFactory.new)
      Factory.register(:sprint, SprintFactory.new)
      Factory.register(:issue, IssueFactory.new)
      Factory.register(:epic, EpicFactory.new)
      Factory.register(:parent_epic, ParentEpicFactory.new)
      Factory.register(:project, ProjectFactory.new)
      Factory.register(:sprint_change_event, SprintChangeEventFactory.new)
      Factory.register(:team, TeamFactory.new)
    end
  end
end
