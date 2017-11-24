class Plan
  include Mongoid::Document
  include Mongoid::Timestamps
  has_many :sites
  validates :customer, presence: true, uniqueness: true
  validates :plan_name, presence: true, uniqueness: true

  field :customer, type: String
  field :plan_name, type: String
  field :hub_arry, type: Array

  #not used
  #before_save :set_hub_arry

  #### not used ####
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
