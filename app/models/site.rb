class Site
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include Mongoid::Attributes::Dynamic

  field :sitename, type: String
  field :address, type: String
  field :coordinates, type: Array
  field :created_at, type:DateTime
  field :updated_at, type:DateTime


  #attr_accessor :sitename, :address, :latitude, :longitude
  #geocoded_by :address, coordinates: :coordinates
  geocoded_by :address
  before_save :geocode


  index({ coordinates: '2dsphere' })

  after_validation :set_coordinates


  private
  def set_coordinates
    self.coordinates = [longitude.to_f, latitude.to_f]
  end

end
