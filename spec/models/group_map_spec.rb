require 'spec_helper'

describe GroupMap do
  before do
    user = User.create(name: 'bob', email: 'whatever@asdf.com')
    @group_map_attrs = { name: 'testgroupmap', owner: user, users: [user]}
  end

  it 'should create a group map' do
    GroupMap.create(@group_map_attrs).is_a?(GroupMap)
  end

  it 'should set player position' do
    gm = GroupMap.create(@group_map_attrs)
    gm.player_positions = {1 => {lat: 3, lng: 4}}
    gm.save
    gm.reload
    gm.player_positions.should == {1 => {lat: 3, lng: 4}}
  end
end
