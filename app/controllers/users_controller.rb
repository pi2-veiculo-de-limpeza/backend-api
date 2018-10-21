class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.all.pluck(:id, :name, :email, :history)

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user.pluck(:id, :name, :email, :history)
  end

  # POST /users
  def create
    @user = User.new(user_params)

    @user = create_token_params(user_params, @user)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :email, :password)
    end

    def create_token_params(api_user_params, api_user)
      random_string = (0..7).map { ('a'..'z').to_a[rand(26)] }.join
      api_user.secret = BCrypt::Password.create(random_string)
      payload = { name: api_user_params[:name], email: api_user_params[:email] }
      api_user.token = JWT.encode payload, api_user.secret, 'HS256'
      api_user
    end
    
end
