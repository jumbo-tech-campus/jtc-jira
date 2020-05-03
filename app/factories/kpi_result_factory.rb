class KpiResultFactory
  def create_from_json(json)
    KpiResult.new(json['result'], json['metrics'])
  end
end
