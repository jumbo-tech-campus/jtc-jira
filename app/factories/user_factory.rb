class UserFactory
  def create_from_hash(hash)
    user = User.new(hash['uid'], hash['info']['name'], hash['info']['email'], hash['provider'])
    user.account_status = hash['info']['account_status']
    user
  end

  def create_from_json(json)
    user = User.new(json['id'], json['name'], json['email'], json['provider'])
    user.account_status = json['account_status']
    user
  end
end
