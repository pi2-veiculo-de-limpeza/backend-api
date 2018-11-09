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

  before_save :create_token_vehicle

  def create_historic current_user
    self.historic = [] if self.historic.nil?
    historic = {
  	 "what" => "inseriu um novo veiculo",
  	 "who" => current_user.id.to_s,
  	 "when" => Time.now
    }

  	self.historic << historic
  end

  def create_token_vehicle
    #begin
      random_string = (0..7).map { ('a'..'z').to_a[rand(26)] }.join
      self.secret = BCrypt::Password.create(random_string)
      payload = { name: self.name, code: self.code }
      self.token = JWT.encode payload, self.secret, 'HS256'
    #end while User.exists?(token: self.token)  
  end
end
