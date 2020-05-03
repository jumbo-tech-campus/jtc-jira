class KpiResult  < ActiveModelSerializers::Model
  attr_reader :result, :metrics

  def initialize(result, metrics)
    @result, @metrics = result, metrics
  end
end
