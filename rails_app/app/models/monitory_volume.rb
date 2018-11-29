class MonitoryVolume < Monitory
  include Mongoid::Document

  NOME_MONITORAMENTO = "Volume Lixeira"
  CENTIMETRO = "centímetro"
  CENTIMETRO_UNIDADE = "cm"

  field :unit_measure, type:String, default:CENTIMETRO

end
