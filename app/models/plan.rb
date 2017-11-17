class Plan
  include Mongoid::Document
  include Mongoid::Timestamps
  has_many :sites

  field :customer, type: String
  field :plan_name, type: String

end
