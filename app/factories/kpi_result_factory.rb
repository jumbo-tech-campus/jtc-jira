class KpiResultFactory
  def create_from_json(json)
    KpiResult.new(json['result'].to_f, json['metrics'])
  end
end
