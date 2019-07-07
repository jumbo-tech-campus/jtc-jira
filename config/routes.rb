Rails.application.routes.draw do
  root 'cycle_time_report#deployment_constraint'
  scope :jira do
    get '/', to: 'cycle_time_report#deployment_constraint'
    resources :teams, only: [:index]
    get 'sprint_report/last_sprint', to: 'sprint_report#last_sprint', as: :last_sprint_report
    get 'sprint_report/sprint', to: 'sprint_report#sprint', as: :sprint_report
    get 'portfolio_report/overview', to: 'portfolio_report#overview', as: :portfolio_report
    get 'portfolio_report/epics_overview', to: 'portfolio_report#epics_overview', as: :portfolio_epics
    get 'portfolio_report/quarter_overview', to: 'portfolio_report#quarter_overview', as: :portfolio_quarter
    match 'cycle_time_report/team', to: 'cycle_time_report#team', as: :cycle_time_team, via: [:get, :post]
    match 'cycle_time_report/deployment_constraint', to: 'cycle_time_report#deployment_constraint', as: :cycle_time_deployment_constraint, via: [:get, :post]
    get 'cycle_time_report/four_week_overview', to: 'cycle_time_report#four_week_overview', as: :cycle_time_four_week_overview
    get 'cycle_time_report/two_week_overview', to: 'cycle_time_report#two_week_overview', as: :cycle_time_two_week_overview
    get 'deployment_report/overview', to: 'deployment_report#overview', as: :deployment_report
    get 'p1_report/overview', to: 'p1_report#overview', as: :p1_report
    post 'sprint_report/refresh_data', to: 'sprint_report#refresh_data', as: :sprint_report_refresh
  end

  resources :teams, only: [:index]
  get 'sprint_report/last_sprint', to: 'sprint_report#last_sprint'
  get 'portfolio_report/overview', to: 'portfolio_report#overview'
  get 'portfolio_report/epics_overview', to: 'portfolio_report#epics_overview'
  get 'portfolio_report/quarter_overview', to: 'portfolio_report#quarter_overview'
  match 'cycle_time_report/team', to: 'cycle_time_report#team', via: [:get, :post]
  match 'cycle_time_report/deployment_constraint', to: 'cycle_time_report#deployment_constraint', via: [:get, :post]
  get 'cycle_time_report/four_week_overview', to: 'cycle_time_report#four_week_overview'
  get 'cycle_time_report/two_week_overview', to: 'cycle_time_report#two_week_overview'
  get 'deployment_report/overview', to: 'deployment_report#overview'
  get 'p1_report/overview', to: 'p1_report#overview'
  get 'sprint_report/sprint', to: 'sprint_report#sprint'
  post 'sprint_report/refresh_data', to: 'sprint_report#refresh_data'
end
