class Route
  include DataMapper::Resource
  property :id, Serial

  has n, :vertices
  belongs_to :vertex0, 'Vertex', required: false

  property :title, String
end
