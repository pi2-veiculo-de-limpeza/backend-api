class Vehicle
  
  include Mongoid::Document
  field :code, type: String
  field :name, type: String
  field :historic, type: Array
  field :speed, type: Float
  field :token, type: String
  field :secret, type: String

  # relacionamentos
  belongs_to :user

  scope:do_user, ->(user_id){self.and(:user_id =>user_id)}

  before_save: create_historic

  def create_historic
  	what = "inseriu um novo veiculo"
  	who_vehicle = current_user
  	when_vehicle = time.now

  	self.historic << [what, who_vehicle, when_vehicle]
  end
end
