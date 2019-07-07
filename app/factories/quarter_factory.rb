class QuarterFactory
  def create_from_json(json)
    Quarter.new(json['start_week'], json['end_week'], json['fix_version'])
  end

  def create_from_hash(hash)
    Quarter.new(hash[:start_week], hash[:end_week], hash[:fix_version])
  end
end
