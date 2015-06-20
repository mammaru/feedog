class Feed < ActiveRecord::Base
  belongs_to :category
  has_many :entries, :dependent => :destroy
end
