class Pop
  require 'csv'
  require 'pp'

  # POP Info <Condifidential>
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include Mongoid::Attributes::Dynamic

  #belongs_to  :site, :inverse_of => :pop

  #attr_accessor :com_popname, :coordinates

  field :sitename, type: String
  field :com_popname, type: String
  field :vpop_name, type: String
  field :address, type: String
  field :coordinates, type: Array
  field :created_at, type:DateTime
  field :updated_at, type:DateTime

  geocoded_by :address
  before_save :geocode

  index({ coordinates: '2dsphere'})

  #after_validation  :set_coordinates

  ## Not working!
  def self.import(file)
    # UTF-8 conversion
    spreadsheet = Roo::Spreadsheet.open(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
    row = Hash[[header, spreadsheet.row(i)].transpose]
    pop = find_by(address: row["address"]) || new
    geocoded_by :address
    before_save :geocode
    pop.attributes = row.to_hash.slice(*updatable_attributes)
    pop.save!
    end
  end

  def self.to_csv(options = {})
    desired_columns = [*exportable_attributes]
    CSV.generate(options) do |csv|
      csv << desired_columns
      all.each do |a|
        csv << a.attributes.values_at(*desired_columns)
      end
    end
  end

  def self.updatable_attributes
    ["sitename","com_popname","address","created_at","coordinates"]
  end

  private
  def set_coordinates
    self.coordinates = [longitude.to_f, latitude.to_f]
  end

end
