class User
  include Mongoid::Document
  field :name, type: String
  field :email, type: String
  field :secret, type: String,   default:nil
  field :token, type: String,    default:nil
  field :password, type: String
  filed :history,  type: Array,  default:nil 
end
