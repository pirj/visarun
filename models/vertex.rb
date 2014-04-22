class Vertex
  include DataMapper::Resource
  property :id, Serial

  property :lat, Float, required: true
  property :lng, Float, required: true

  property :caption, String

  belongs_to :route
  belongs_to :previous, self, required: false
end
