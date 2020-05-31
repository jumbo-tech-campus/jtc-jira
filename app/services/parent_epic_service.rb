class ParentEpicService
  def initialize(fix_version)
    @fix_version = fix_version
    @parent_epics = Repository.for(:parent_epic).find_by(fix_version: @fix_version)
  end

  def epics_report
    {
      table: epics_report_table
    }
  end

  private

  def epics_report_table
    table = []
    header = %w[Assignee Key Title Summary]
    table << header
    @parent_epics.each do |parent_epic|
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
