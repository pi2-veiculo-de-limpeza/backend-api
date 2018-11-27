class Mission
  include Mongoid::Document

  STATUS_CREATE = 'criado'
  STATUS_ANDAMENTO = "Andamento"
  STATUS_CONCLUIDO = "Concluído"
  STATUS_CANCELADO = "Cancelado"


  field :coordenates, type: Array, default: nil #[{"longetude": 234, "latitude": 234}, {"longetude": 123, "latitude": 123}, {"longetude": 123, "latitude": 123}, {"longetude": 123, "latitude": 123}]
  field :name, type: String
  field :area_mission, type: Array, default: nil
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


  before_save :seta_status

  def seta_status
  		self.status = STATUS_CREATE
  end

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
  
end
