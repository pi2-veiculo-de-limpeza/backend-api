class Mission
  include Mongoid::Document

  STATUS_CREATE = 'criado'
  STATUS_ANDAMENTO = "Andamento"
  STATUS_CONCLUIDO = "Concluído"
  STATUS_CANCELADO = "Cancelado"


  field :mapa_mission, type: Array
  field :name, type: String
  field :area_mission, type: Array
  field :time_conclusion, type: Time
  field :time_travel, type: Time
  field :status, type: String
  field :historic, type: Array

  belongs_to :vehicle

  validates :name, presence: true
  validates :area_mission, presence: true

  before_save :seta_status

  def seta_status
  		self.status = STATUS_CREATE
  end

  def create_historic current_user, msg=nil
    self.historic = []
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
  
end
