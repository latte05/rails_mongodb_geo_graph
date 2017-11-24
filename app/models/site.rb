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

  def get_e2e_latency(hub)
    ## pp_arr = pop to pop array [latency, sla]
    ## al_aar1 = @site al [latency, sla]
    ## al_arr2 = @hub al [latency, sla]
    ## resut is sum of each array and return end to end latency array [latency, sla]
    if self.s2p_est_latency.nil? || hub.s2p_est_latency.nil?
      return ["n/a", "n/a"]
    elsif self == hub
      return ["n/a", "n/a"]
    elsif
      pp_arr = get_p2p_latency(hub.pop_assigned)
      if pp_arr == ["n/a","n/a"]
        return ["n/a","n/a"]
      end
        puts "Site PE Name: #{self.pop_assigned}"
        puts "Hub PE Name: #{hub.pop_assigned}"
        al_arr1 = [self.s2p_est_latency, self.s2p_sla_latency]
        al_arr2 = [hub.s2p_est_latency, hub.s2p_sla_latency]
        ## sum of each array element
        result = pp_arr.zip(al_arr1).map{|f,s| f+s.round(3)}
        result = result.zip(al_arr2).map{|f,s| f+s.round(3)}
        puts "E2E Latency #{result[0]}"
        puts "E2E SLA #{result[1]}"
        return result
     end
  end

  def get_p2p_latency(hub)
    pop1 = self.pop_assigned
    pop2 = hub
      if pop1 < pop2
        instance_name = pop1 + "-" + pop2 + "_Standard"
      elsif pop1 == pop2
        instance_name = "same hub"
        ## if it's same hub latency is 0 ms and 2ms for SLA
        return [0, 2]
      elsif
        instance_name = pop2 + "-" + pop1 + "_Standard"
      end
      puts "Instance Name: " + instance_name #debug
      @latency = Latency.find_by(:instance => instance_name)
      p2p_latency = !@latency.nil? ? @latency.raw_latency.round(3) : "n/a"
      p2p_sla = !@latency.nil? ? @latency.sla_threshold.round(3) : "n/a"
      puts "P2P Latency: #{p2p_latency}"
      puts "P2P SLA: #{p2p_sla}"
      return [p2p_latency, p2p_sla]
  end

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
      self.s2p_est_latency = (((al_distance)*0.02) + 5).round(3)
      self.s2p_sla_latency = (s2p_est_latency*1.3).round(3)
    end
  end

end
