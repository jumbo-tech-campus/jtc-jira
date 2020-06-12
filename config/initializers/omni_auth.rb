require 'omniauth/strategies/jira'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :jira, ENV['JIRA_CLIENT_ID'], ENV['JIRA_CLIENT_SECRET'], {
    scope: 'offline_access read:me',
    prompt: 'consent',
    redirect_uri: "#{ENV['APP_URL']}/auth/jira/callback"
  }
end

OmniAuth.config.logger = Rails.logger
