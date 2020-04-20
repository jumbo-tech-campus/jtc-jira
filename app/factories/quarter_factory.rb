class QuarterFactory
  def create_from_json(json)
    Quarter.new(json['id'], json['start_week'], json['end_week'], json['fix_version'], json['year'].to_i)
  end

  def create_from_hash(hash)
    Quarter.new(hash[:id], hash[:start_week], hash[:end_week], hash[:fix_version], hash[:year])
  end
end
