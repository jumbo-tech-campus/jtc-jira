# frozen_string_literal: true

require 'securerandom'

class KpiGoalsController < ApplicationController
  before_action :set_kpi_goal, only: %i[show edit update destroy]
  before_action :set_department, only: %i[index new]
  before_action :set_quarters, only: %i[new edit update]

  def index
    @kpi_goals = Repository.for(:kpi_goal).find_by(department: @department)
  end

  def show; end

  def new
    @kpi_goal = KpiGoal.new(SecureRandom.uuid, @quarter, @department)
  end

  def edit
    @department = @kpi_goal.department
  end

  def create
    @kpi_goal = Factory.for(:kpi_goal).create_from_hash(kpi_goal_params)
    @kpi_goal.calculate_kpi_result
    Repository.for(:kpi_goal).save(@kpi_goal)

    redirect_to kpi_goals_url(department_id: @kpi_goal.department.id), notice: 'Kpi goal was successfully created.'
  end

  def update
    @kpi_goal = Factory.for(:kpi_goal).create_from_hash(kpi_goal_params)
    @kpi_goal.calculate_kpi_result
    Repository.for(:kpi_goal).save(@kpi_goal)

    redirect_to kpi_goals_url(department_id: @kpi_goal.department.id), notice: 'Kpi goal was successfully updated.'
  end

  def destroy
    Repository.for(:kpi_goal).delete(@kpi_goal)
    redirect_to kpi_goals_url(department_id: @kpi_goal.department.id), notice: 'Kpi goal was successfully destroyed.'
  end

  private

  def set_kpi_goal
    @kpi_goal = Repository.for(:kpi_goal).find(params[:id])
  end

  def set_department
    department_id = params[:department_id] || '1'
    @department = Repository.for(:department).find(department_id.to_i)
  end

  def kpi_goal_params
    params.require(:kpi_goal).permit(:type, :metric, :quarter_id, :id, :department_id)
  end

  def set_quarters
    @quarters = Repository.for(:quarter).all
    @quarter = Repository.for(:quarter).find_by(date: Date.today)
  end
end
