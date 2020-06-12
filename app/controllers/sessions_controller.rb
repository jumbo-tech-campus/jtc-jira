class SessionsController < ApplicationController
  before_action :validate_email, only: :create

  def new
    redirect_to '/auth/jira'
  end

  def create
    user = Repository.for(:user).find(auth_hash['uid']) || Factory.for(:user).create_from_hash(auth_hash)

    user.account_status = auth_hash[:account_status]
    Repository.for(:user).save(user)

    reset_session

    session[:user_id] = user.id
    redirect_to department_report_kpi_dashboard_path
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'Logged out successfully'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  def validate_email
    email = auth_hash['info']['email']
    unless email.ends_with?('@jumbo.com')
      redirect_to root_path, alert: "Invalid email address #{email} - only Jumbo employees allowed"
    end
  end
end
