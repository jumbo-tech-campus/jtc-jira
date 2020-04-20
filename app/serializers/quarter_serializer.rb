class QuarterSerializer < ActiveModel::Serializer
  attributes :id, :start_week, :end_week, :fix_version, :year
end
