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

    wbso_projects = parent_epics.inject([]) do |memo, parent_epic|
      memo << parent_epic.wbso_project unless memo.include?(parent_epic.wbso_project) || parent_epic.wbso_project.nil?
      memo
    end

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
            row_value = sprint_parent_epic.percentage_of_points_closed.round
          end
        end
        row << row_value
      end
      table << row
    end

    wbso_projects.each do |wbso_project|
      wbso_row = ["WBSO - #{wbso_project}", nil]

      teams.inject({}) do |memo, team|
        sprint = Repository.for(:board).find(team.board_id).sprint_for(date)
        if sprint && sprint.wbso_issues.size > 0
          wbso_row  << sprint.wbso_percentage_of_points_closed_per_wbso_project[wbso_project]&.round
        else
          wbso_row << nil
        end
      end
      table << wbso_row
    end
    table
  end
end
