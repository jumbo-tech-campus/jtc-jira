Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'sprint_report/last_sprint', to: 'sprint_report#last_sprint'
end
