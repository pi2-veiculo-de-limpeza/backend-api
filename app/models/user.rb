class User
  include Mongoid::Document
  field :name, type: String
  field :email, type: String
  field :secret, type: String,   default:nil
  field :token, type: String,    default:nil
  field :password, type: String
  field :history,  type: Array,  default:nil
  field :logged_on, type:Boolean, default:false

  #validates

  validates_uniqueness_of :email

  before_save :create_token

  def create_token
  	#begin
  		random_string = (0..7).map { ('a'..'z').to_a[rand(26)] }.join
    	self.secret = BCrypt::Password.create(random_string)
    	payload = { name: self.name, email: self.email }
    	self.token = JWT.encode payload, self.secret, 'HS256'
    #end while User.exists?(token: self.token)	
  end

  def authenticate? password
  	if password == self.password
  		true
  	else
  		false
  	end
  end

end
