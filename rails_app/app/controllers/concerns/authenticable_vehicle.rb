module AuthenticableVehicle
	def current_vehicle
		@current_vehicle ||= Vehicle.where(token: request.headers['Authorization']).first
	end

	def authenticate_with_token_vehicle!
		render json: {errors: "Unauthorized access!"}, status: 401 unless current_vehicle.present?	
	end

	def vehicle_loggen_in?
		current_vehicle.present?
	end

end