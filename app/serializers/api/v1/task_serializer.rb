class Api::V1::TaskSerializer < ApplicationSerializer
  attributes :id, :title
  has_many :tags, serializer: Api::V1::TagSerializer
end
