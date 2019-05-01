class Api::V1::TagSerializer < ApplicationSerializer
  attributes :id, :title
  has_many :tasks, serializer: Api::V1::TaskSerializer
end
