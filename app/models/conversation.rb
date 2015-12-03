class Conversation
  include Mongoid::Document
  field :data, type: String
  scope :by_id, ->(id) { where(id: id) }
end
