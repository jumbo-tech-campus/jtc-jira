class PortfolioReportService
  def self.for(teams, date)
    team_sprint_parent_epics = teams.inject({}) do |memo, team|
      sprint = Repository.for(:board).find(team.board_id).sprint_for(date)

      memo[team.name] = sprint&.sprint_parent_epics || []
      memo
    end

    team_wbso_percentages = teams.inject({}) do |memo, team|
      sprint = Repository.for(:board).find(team.board_id).sprint_for(date)

      memo[team.name] = sprint&.wbso_percentage_of_issues_closed || 0
      memo
    end

    parent_epics = team_sprint_parent_epics.values.inject([]) do |memo, sprint_parent_epics|
      sprint_parent_epics.each do |sprint_parent_epic|
        memo << sprint_parent_epic.parent_epic unless memo.include?(sprint_parent_epic.parent_epic)
      end
      memo
    end

    parent_epics.sort_by!{ |parent_epic| parent_epic.id }

    table = []
    header = [nil, 'WBSO']
    teams.each do |team|
      header << team.name
    end
    table << header

    parent_epics.each do |parent_epic|
      wbso = 'x' if parent_epic.wbso_project.present?
      row = [parent_epic.description, wbso]

      team_sprint_parent_epics.values.each do |sprint_parent_epics|
        row_value = nil
        sprint_parent_epics.each do |sprint_parent_epic|
          if sprint_parent_epic.parent_epic == parent_epic && sprint_parent_epic.percentage_of_points_closed > 0
            row_value = sprint_parent_epic.percentage_of_points_closed.round(1)
          end
        end
        row << row_value
      end
      table << row
    end

    wbso_row = ['WBSO - Issues eligible for WBSO subsidy', nil]
    team_wbso_percentages.each do |team_name, percentage|
      wbso_row  << percentage.round(1)
    end

    table << wbso_row
    table
  end
end
