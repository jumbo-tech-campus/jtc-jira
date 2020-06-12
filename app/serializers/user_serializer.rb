class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :account_status, :provider
end
