class User
  include Mongoid::Document
  field :name, type: String
  field :email, type: String
  field :secret, type: String,   default:nil
  field :token, type: String,    default:nil
  field :password, type: String
  field :history,  type: Array,  default:nil

  def create_token
  end 
end
