class Mission
  include Mongoid::Document
  field :mapa_mission, type: Array
  field :name, type: String
  field :area_mission, type: Array
  field :time_conclusion, type: Time
  field :time_travel, type: Time
  field :status, type: String
  field :historic, type: Array
end
