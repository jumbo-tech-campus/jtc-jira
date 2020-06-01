module Cache
  class TeamSprintRepository
    def find_by(options)
      if options[:id] && options[:team]
        if options[:team].is_scrum_team?
          sprint = Repository.for(:sprint).find_by(id: options[:id], board: options[:team].board)
          TeamSprint.new(options[:team], sprint)
        else
          year_week = options[:id].split('_')
          options[:team].sprint_for(Date.commercial(year_week[0].to_i, year_week[1].to_i, 1))
        end
      end
    end
  end
end
