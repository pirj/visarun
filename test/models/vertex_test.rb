require_relative '../test_helper'

describe Vertex do
  it 'can be created' do
    vertex = create :vertex
    refute_nil vertex.id
  end

  it 'can be created in chain' do
    vertex = create :vertex_chain
    refute_nil vertex.id
    refute_nil vertex.previous_id
  end

  it 'validates presence of txn_id' do
    order = create :order, txn_id: nil
    assert_equal false, order.save
    assert_nil order.id
  end
end
