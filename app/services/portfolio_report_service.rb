class PortfolioReportService
  def self.for_sprints_on(date)
    teams = Repository.for(:team).all

    team_sprint_parent_epics = teams.inject({}) do |memo, team|
      sprint = Repository.for(:board).find(team.board_id).sprint_for(date)
      memo[team.name] = sprint&.sprint_parent_epics || []
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
    header = [nil]
    teams.each do |team|
      header << team.name
    end
    table << header

    parent_epics.each do |parent_epic|
      row = [parent_epic.description]

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

    table
  end
end
