class SessionsController < ApplicationController
	def create
		@user = User.find_by(email: session_params['email'])
		if @user and @user.authenticate?(session_params[:password])
			@user.logged_on = true
			@user.save!
			render json: @user, status: 200
		else
			render json: "email ou senha incorretos", status: 404
		end
	end

	private

	def session_params
		params.require(:session).permit(:email, :password)
	end

end
