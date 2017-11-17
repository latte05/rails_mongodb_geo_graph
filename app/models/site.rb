class Site
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include Mongoid::Attributes::Dynamic
  belongs_to :plan
  validates :plan_id, presence: true

  #has_one :pop
  #accepts_nested_attributes_for :pop

  field :site_name, type: String
  field :address, type: String
  field :coordinates, type: Array
  field :longitude, type: Float
  field :latitude, type: Float
  field :created_at, type: DateTime
  field :updated_at, type: DateTime
  field :pop_assigned, type: String
  field :pop_coordinates, type: Array
  field :al_distance, type: Float
  field :s2p_est_latency, type: Float
  field :s2p_sla_latency, type: Float
  field :hub_status, type: Boolean, default: false


  #attr_accessor :site_name, :address, :latitude, :longitude
  #geocoded_by :address, coordinates: :coordinates
  after_validation :geocode
  after_validation :set_coordinates

  geocoded_by :address
  index({ coordinates: '2dsphere' })

  before_save :set_pop_coordinates
  before_save :set_al_params

  private
  def set_coordinates
    # if user wants to set latitude and longitude, update the coordinates
    if !latitude.nil? || !longitude.nil?
      self.coordinates = [latitude.to_f, longitude.to_f]
    end
  end

  def set_pop_coordinates
    if pop_assigned?
     @pop = Pop.find_by(:com_popname => pop_assigned)
     self.pop_coordinates = @pop.to_coordinates
    end
  end

  def set_al_params
    if !self.coordinates.nil? && !self.pop_coordinates.nil?
      #this is based on mongodb database to handle coordinates.
      self.al_distance = Geocoder::Calculations.distance_between(self.to_coordinates, self.pop_coordinates, :units => :km).round(3)
      # estimated lateny is 5msec + AL*0.02 / SLA is estimated latency * 1.3
      self.s2p_est_latency = ((al_distance)*0.02).round(3) + 5
      self.s2p_sla_latency = (s2p_est_latency*1.3).round(3)
    end
  end

end
