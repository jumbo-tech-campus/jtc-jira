class KpiGoalSerializer < ActiveModel::Serializer
  attributes :id, :type, :metric, :quarter_id, :department_id
end
