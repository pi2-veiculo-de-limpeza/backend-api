class SessionsController < ApplicationController

	def create
		@user = User.where(email: session_params['email']).first
		if not @user.nil? and @user.authenticate?(session_params[:password])
			@user.logged_on = true
			@user.save!
			render json: @user, status: 200
		else
			render json: {erro: "email ou senha incorretos"}, status: 404
		end
	end

	def destroy
		user = User.find_by(token: params['token'])
		if user
			user.logged_on = false
			user.save!
			head 204
		end

	end

	private

	def session_params
		params.require(:session).permit(:email, :password)
	end

end
