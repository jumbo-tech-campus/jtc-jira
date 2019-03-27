Rails.application.routes.draw do
  root 'teams#index'
  scope :jira do
    get '/', to: 'teams#index', as: :home
    resources :teams, only: [:index]
    get 'sprint_report/last_sprint', to: 'sprint_report#last_sprint', as: :last_sprint_report
    get 'sprint_report/sprint', to: 'sprint_report#sprint', as: :sprint_report
    get 'report/portfolio', to: 'report#portfolio', as: :portfolio_report
    get 'report/cycle_time', to: 'report#cycle_time', as: :cycle_time_report
    get 'report/deployment', to: 'report#deployment', as: :deployment_report
    post 'sprint_report/refresh_data', to: 'sprint_report#refresh_data', as: :sprint_report_refresh
  end

  resources :teams, only: [:index]
  get 'sprint_report/last_sprint', to: 'sprint_report#last_sprint'
  get 'report/portfolio', to: 'report#portfolio'
  get 'report/cycle_time', to: 'report#cycle_time'
  get 'report/deployment', to: 'report#deployment'
  get 'sprint_report/sprint', to: 'sprint_report#sprint'
  post 'sprint_report/refresh_data', to: 'sprint_report#refresh_data'
end
