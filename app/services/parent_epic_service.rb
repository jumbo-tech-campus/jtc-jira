class ParentEpicService
  def initialize(fix_version = nil)
    @fix_version = fix_version
  end

  def epics_report
    {
      table: epics_report_table
    }
  end

  def associate_epics_to_parent_epic
    parent_epics.each do |parent_epic|
      epics = Repository.for(:epic).find_by(parent_epic: parent_epic)
      parent_epic.epics.concat(epics)
    end
  end

  def parent_epics
    @parent_epics ||= retrieve_parent_epics
  end

  private
  def retrieve_parent_epics
    parent_epics = Repository.for(:issue_collection).find(3).issues
    parent_epics = parent_epics.select{ |parent_epic| parent_epic.fix_version == @fix_version } if @fix_version
    parent_epics
  end

  def epics_report_table
    table = []
    header = ["Assignee", "Key", "Title", "Summary"]
    table << header
    parent_epics.each do |parent_epic|
      table << [
        parent_epic.assignee,
        parent_epic.key,
        parent_epic.summary,
        nil
      ]
      parent_epic.epics.each do |epic|
        table << [
          nil,
          epic.key,
          epic.name,
          epic.summary
        ]
      end
    end

    table
  end
end
