require 'spec_helper'

describe Scooter do
  it 'has a version number' do
    expect(Scooter::Version::STRING.dup).not_to be nil
  end
end
