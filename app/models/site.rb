class Site
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include Mongoid::Attributes::Dynamic
  #has_one :pop
  #accepts_nested_attributes_for :pop


  field :sitename, type: String
  field :address, type: String
  field :coordinates, type: Array
  field :longitude, type: Float
  field :latitude, type: Float
  field :created_at, type: DateTime
  field :updated_at, type: DateTime
  field :pop_assigned, type: String
  field :pop_coordinates, type: Array
  field :access_distance, type: Float


  #attr_accessor :sitename, :address, :latitude, :longitude
  #geocoded_by :address, coordinates: :coordinates
  geocoded_by :address
  before_save :geocode


  index({ coordinates: '2dsphere' })

  after_validation :set_coordinates, :set_pop_coordinates

  private
  def set_coordinates
    self.coordinates = [longitude.to_f, latitude.to_f]
  end

  def set_pop_coordinates
    if pop_assigned?
     @pop = Pop.find_by(:com_popname => pop_assigned)
     self.pop_coordinates = @pop.coordinates
   end
  end

end
