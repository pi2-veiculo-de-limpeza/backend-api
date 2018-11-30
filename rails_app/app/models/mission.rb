class Mission
  include Mongoid::Document

  STATUS_CREATE = 'criado'
  STATUS_ANDAMENTO = "Andamento"
  STATUS_CONCLUIDO = "Concluído"
  STATUS_CANCELADO = "Cancelado"


  field :coordinates, type: Array, default: nil #[{"longitude": 234, "latitude": 234}, {"longitude": 123, "latitude": 123}, {"longitude": 123, "latitude": 123}, {"longitude": 123, "latitude": 123}]
  field :name, type: String
  field :area_mission, type: Array, default: [0, 0, 0] #[120, 15, 8] => area_total, comprimento, largura
  field :time_conclusion, type: Time, default:nil
  field :time_travel, type: Time, default: nil
  field :status, type: String, default: STATUS_CREATE
  field :historic, type: Array, default: nil
  field :copy_vehicle, type: Hash, default: nil #{"vehicle_name" => "veiculo1", "vehicle_speed"=> 1.23, "vehicle_code"=>"ad8q948cbsdhfb987"}

  belongs_to :vehicle


  validates :name, presence: true
  #validates :area_mission, presence: true

  scope :do_vehicle, ->(vehicle_id) { self.and(:vehicle_id => vehicle_id) }
  scope :dos_vehicles, ->(vehicles_ids) { self.and(:vehicle_id.in => vehicles_ids) }
  scope :em_andamento, ->() {self.and(:status=>STATUS_ANDAMENTO)}


  def create_historic current_user, msg=nil
    self.historic = [] if self.historic.nil?
    if msg.nil?
	    historic = {
	  	 "what" => "criou esta missão",
	  	 "who" => current_user.id.to_s,
	  	 "when" => Time.now
	    }
	else
		historic = {
	  	 "what" => msg,
	  	 "who_mission" => current_user.id.to_s,
	  	 "when_mission" => Time.now
	    }
	end

  	self.historic << historic
  end

  def altera_status status
  	if not status.nil?
  		self.status = status
      self.save!
  	else
  		"erro ao tentar alterar status"
  	end

  end

  def faz_copia_vehicle vehicle
    if vehicle
      copy_vehicle = {
                        "vehicle_name" => vehicle.name, 
                        "vehicle_speed"=> vehicle.speed, 
                        "vehicle_code"=>  vehicle.code
                      }
      self.copy_vehicle = copy_vehicle
      
    end                
  end

  def calculator_area_mission
    if not self.coordinates.nil?
      area_mission = []
      coordinates_array = []
      self.coordinates.each do |coordinate|
        coordinates_array << [coordinate[:latitude], coordinate[:longitude]]
      end

      result1 = Geocoder::Calculations.distance_between(coordinates_array[0], coordinates_array[1])
      area_mission << result1
      result2 = Geocoder::Calculations.distance_between(coordinates_array[2], coordinates_array[3])
      area_mission << result2
      result3 = Geocoder::Calculations.distance_between(coordinates_array[0], coordinates_array[2])
      area_mission << result3
      result4 = Geocoder::Calculations.distance_between(coordinates_array[1], coordinates_array[3])
      area_mission << result4

      area_mission = area_mission.sort

      whidth = ((area_mission[0] * 1000 + area_mission[1] * 1000)/2).round
      lenght = ((area_mission[2] * 1000 + area_mission[3] * 1000)/2).round

      area_total = whidth * lenght

      self.area_mission = [area_total, lenght, whidth]
      self.save

    end
  end


  def self.estatisticas_raw_vehicle criteria, vehicle

    result = {"concluidas": 0,
              "canceladas": 0,
              "criada": 0,
              "andamento": 0,
              "lixerira_cheia": false,
              "total": 0,
              "total_lixo_coletado": 0,
              "total_area_missao": 0,
              "area_por_missao": {},
              "missao":{},
              "vehicle":{},
              "lixo_por_missao": {}
              };

    result[:vehicle][vehicle.id.to_s] = [vehicle.name, vehicle.speed]

    criteria.each do |mission|
        if mission.status == "Andamento"
          result[:andamento] += 1;
        elsif mission.status == "Concluído"
          result[:concluidas] += 1;
        elsif mission.status == "Cancelado"
          result[:canceladas] += 1;
        else
          result[:criada] += 1;
        end

        result[:total_area_missao] = mission.area_mission[0]
        result[:area_por_missao][mission.id.to_s] =  mission.area_mission[0]
        result[:missao][mission.id.to_s] = mission.name

        result[:total] += 1

        @monitory = MonitoryWeight.da_mission(mission.id)
        if @monitory
          @monitory.each do |monitory|
            result[:lixo_por_missao][mission.id.to_s] = 0 if result[:lixo_por_missao][mission.id.to_s].blank?
            if monitory._type == "MonitoryWeight"
              result[:lixo_por_missao][mission.id.to_s] = monitory.measure_value if monitory.measure_value > result[:lixo_por_missao][mission.id.to_s]
            end
          end
        end

        result[:total_lixo_coletado] += result[:lixo_por_missao][mission.id.to_s]
    end
    result
  end
end
