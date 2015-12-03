class Conversation
  include Mongoid::Document
  field :data, type: Hash
  scope :by_id, ->(id) { where(id: id) }
end

