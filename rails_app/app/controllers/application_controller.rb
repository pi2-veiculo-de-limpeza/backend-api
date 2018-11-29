class ApplicationController < ActionController::API
	include Authenticable
	include AuthenticableVehicle
end
