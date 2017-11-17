class Latency

  require 'csv'
  require 'pp'

  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include Mongoid::Attributes::Dynamic

  validates "instance", presence: true, uniqueness: true
  after_validation :set_nodes, on: :create
  before_save :set_section_array, :set_history_array


  field :instance, type: String
  field :section, type: Array
  field :node_from, type: String
  field :node_to, type: String
  field :timestamps, type:DateTime
  field :raw_latency, type:Float
  field :sla_threshold, type:Float
  #  [node_from, node_to]
  # [{:node_from; :node_to; latency: float, SLA: float, recoreded_at} ]
  field :history, type: Array
  # [{timestamps, latency, sla}]
  field :created_at, type:DateTime
  field :updated_at, type:DateTime

  index({ instance: 1}, {unique: true, name: "instance_index" })


  after_update do
      self.history << history_was if history_changed?
  end

  def self.import(file)
    # UTF-8 conversion
    spreadsheet = Roo::Spreadsheet.open(file)
    spreadsheet.default_sheet = '2015_10'
    header = spreadsheet.row(2)
    (3..spreadsheet.last_row).each do |i|

    row = Hash[[header, spreadsheet.row(i)].transpose]
    latency = find_by(instance: row["instance"]) || new
    latency.attributes = row.to_hash.slice(*updatable_attributes)
    latency.save!
    end
  end

    def self.updatable_attributes
      ["instance","section","node_from","node_to","address","raw_latency","sla_threshold","timestamps","history"]
    end

  private
    #set section
    def set_section_array
      self.section = [:node_from => node_from, :node_to => node_to] unless !nil
    end

    #insert historical update into history array
    def set_history_array
      if self.history == nil
       self.history = [:timestamps => timestamps, :raw_latency => raw_latency.to_f, :sla_threshold => sla_threshold.to_f]
     else
       self.history << [:timestamps => timestamps, :raw_latency => raw_latency.to_f, :sla_threshold => sla_threshold.to_f]
     end
    end

    #split to array - and _ e.g. AMS1-STM1_Standard -> AMS1, STM1, Standard
    def set_nodes
      #set nodes if node-fro or node-to is nul
      if node_from ='nul' || node_to ='nul'
          tmp = self.instance
          tmpAry = tmp.split(/\p{Punct}/)
          self.node_from = tmpAry[0]
          self.node_to = tmpAry[1]
          self.section = [:node_from => tmpAry[0], :node_to => tmpAry[1]]
      end
    end
  end
