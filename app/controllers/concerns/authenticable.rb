module Authenticable

	def current_user
		@current_user ||= User.where(token: request.headers['Authorization']).first
	end

	def authenticate_with_token!
		render json: {errors: "Unauthorized access!"}, status: 401 unless current_user.present?
			
	end

	def user_loggen_in?
		current_user.present?
	end


end