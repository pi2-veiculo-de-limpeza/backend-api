class MonitoringController < ApplicationController
	before_action :authenticate_with_token_vehicle!
	before_action :authenticate_with_token!, only: [:get_weight, :get_volume_dump]
	
	def create_monitoring_weight

		if params["peso"].nil?
			render json: {errors: "você esqueceu de enviar o peso"}, status: 400
		elsif params["mission_id"].nil?
			render json: {errors: "você esqueceu de enviar a missão que está em execução"}, status: 400
		elsif params["time_measuring"].nil?
			render json: {errors: "você esqueceu de enviar a hora do envio"}, status: 400	
		else
			peso = params["peso"]
			mission = Mission.find(params['mission_id'])
			time_measuring = Time.zone.parse(params["time_measuring"]).utc

			
			@monitoring_weight = MonitoryWeight.new(time_measuring: time_measuring, measure_value: peso, mission: mission, vehicle: current_vehicle)

			if @monitoring_weight.save!
				render status: :created
			else
				render json: @monitoring_weight.error, status: 400
			end

		end
	end

	def get_weight

		if params["mission_id"]
			@monitoring_weight = MonitoryWeight.where(mission_id: params["mission_id"]).last
		else
			@monitoring_weight = MonitoryWeight.last
		end

	end

	def create_monitoring_volume_dump

		if params["volume"].nil?
			render json: {errors: "você esqueceu de enviar o volume da lixeira"}, status: 400
		elsif params["mission_id"].nil?
			render json: {errors: "você esqueceu de enviar a missão que está em execução"}, status: 400
		elsif params["time_measuring"].nil?
			render json: {errors: "você esqueceu de enviar a hora do envio"}, status: 400	
		else
			volume = params["volume"]
			mission = Mission.find(params['mission_id'])
			time_measuring = Time.zone.parse(params["time_measuring"]).utc
			@monitoring_volume = MonitoryVolume.new(time_measuring: time_measuring, measure_value: volume, mission: mission, vehicle: current_vehicle)

			if @monitoring_volume.save!
				render status: :created
			else
				render json: @monitoring_volume.error, status: 400
			end

		end
	end

	def get_volume_dump

		if params["mission_id"]
			@monitoring_volume = MonitoryVolume.where(mission_id: params["mission_id"]).last
		else
			@monitoring_volume = MonitoryVolume.last
		end
	end
end
