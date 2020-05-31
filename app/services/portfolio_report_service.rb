class PortfolioReportService
  def initialize(teams, date)
    @teams = teams
    @date = date
    @small_changes_epic = Repository.for(:parent_epic).find('PK-246')
    @static_epics = [@small_changes_epic, Repository.for(:parent_epic).find('PK-341')]
    @static_epics.each { |epic| epic.fix_versions.clear }
  end

  def team_report
    table = []
    header = [nil, 'Plan', 'WBSO']
    @teams.each do |team|
      header << team.name
    end
    table << header

    parent_epic_rows(table, @static_epics, { include_wbso: true, include_fix_version: true })
    parent_epic_rows(table, team_parent_epics.reject { |parent_epic| @static_epics.include?(parent_epic) }, { include_wbso: true, include_fix_version: true })

    wbso_projects(team_parent_epics).each do |wbso_project|
      wbso_row = ["WBSO - #{wbso_project}", nil, nil]

      @teams.inject({}) do |_memo, team|
        sprint = team.sprint_for(@date)
        wbso_row << if sprint && !sprint.wbso_issues.empty?
                      sprint.wbso_percentage_of_points_closed_per_wbso_project[wbso_project]&.round
                    end
      end
      table << wbso_row
    end

    table
  end

  def portfolio_export_report
    table = []
    header = [nil]
    @teams.each do |team|
      header << team.name
    end
    table << header

    quarter = Repository.for(:quarter).find_by(date: @date)
    parent_epics = Repository.for(:parent_epic).find_by(fix_version: quarter.fix_version).sort_by(&:id)
    parent_epics -= @static_epics

    parent_epic_rows(table, @static_epics, { merge_no_epic_into_small_changes: true, include_fix_version: false, include_empty_lines: true })
    parent_epic_rows(table, parent_epics, { include_empty_lines: true })
    table
  end

  def team_sprint_parent_epics
    @team_sprint_parent_epics ||= @teams.each_with_object({}) do |team, memo|
      sprint = team.sprint_for(@date)

      memo[team.name] = sprint&.sprint_parent_epics || []
    end
  end

  def team_wbso_percentages
    @team_wbso_percentages = @teams.each_with_object({}) do |team, memo|
      sprint = team.sprint_for(@date)

      memo[team.name] = sprint&.wbso_percentage_of_issues_closed || 0
    end
  end

  def team_parent_epics
    @team_parent_epics ||= team_sprint_parent_epics.values.each_with_object([]) do |sprint_parent_epics, memo|
      sprint_parent_epics.each do |sprint_parent_epic|
        memo << sprint_parent_epic.parent_epic unless memo.include?(sprint_parent_epic.parent_epic)
      end
    end.sort_by(&:id)
  end

  def wbso_projects(parent_epics)
    @wbso_projects ||= parent_epics.each_with_object([]) do |parent_epic, memo|
      memo << parent_epic.wbso_project unless memo.include?(parent_epic.wbso_project) || parent_epic.wbso_project.nil?
    end
  end

  def parent_epic_rows(table, parent_epics, options = {})
    parent_epics.each do |parent_epic|
      row = [parent_epic.description]
      row << parent_epic.fix_versions_string if options[:include_fix_version]
      if parent_epic.wbso_project.present? && options[:include_wbso]
        row << 'x'
      elsif options[:include_wbso]
        row << nil
      end
      skip_row = true

      if parent_epic == @small_changes_epic && options[:merge_no_epic_into_small_changes]
        # find both small changes epic and not defined epic
        team_sprint_parent_epics.values.each do |sprint_parent_epics|
          row_value = 0
          sprint_parent_epics.each do |sprint_parent_epic|
            if (sprint_parent_epic.parent_epic.id == 0 || sprint_parent_epic.parent_epic == @small_changes_epic) && sprint_parent_epic.percentage_of_points_closed > 0
              row_value += sprint_parent_epic.percentage_of_points_closed.round
            end
          end
          row_value = nil if row_value == 0

          row << row_value
        end
      else
        team_sprint_parent_epics.values.each do |sprint_parent_epics|
          row_value = nil
          sprint_parent_epics.each do |sprint_parent_epic|
            if sprint_parent_epic.parent_epic == parent_epic && sprint_parent_epic.percentage_of_points_closed > 0
              row_value = sprint_parent_epic.percentage_of_points_closed.round
            end
          end
          row << row_value
          skip_row = false if row_value
        end
      end
      table << row unless skip_row && !options[:include_empty_lines]
    end
  end
end
