class DepartmentFactory
  def create_from_hash(hash)
    Department.new(hash[:id], hash[:name])
  end

  def create_from_json(json)
    Department.new(json['id'], json['name'])
  end
end
