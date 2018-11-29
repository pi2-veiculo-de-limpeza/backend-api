class MonitoryWeight < Monitory
  include Mongoid::Document

  NOME_MONITORAMENTO = "Peso Lixo"
  KILOGRAMA = "Kg"
  GRAMA = "g"

  field :unit_measure, type:String, default:GRAMA

  #scope :do_vehicle, ->(vehicle_id) {self.and(:vehicle_id=>vehicle_id)}
  #scope :da_mission, ->(mission_id) {self.and(:mission_id=>mission_id)}


end
