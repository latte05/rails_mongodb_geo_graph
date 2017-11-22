class Plan
  include Mongoid::Document
  include Mongoid::Timestamps
  has_many :sites

  field :customer, type: String
  field :plan_name, type: String
  field :hub_arry, type: Array

  before_save :set_hub_arry

  private
    def set_hub_arry
      self.hub_array.clear if !nil
        self.sites.each do |hub|
            if hub.hub_status == true
              self.hub_arry.push(hub.pop_assigned)
            end
      end

  end # end of private
end #enf of class
