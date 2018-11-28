class MissionsController < ApplicationController
  before_action :set_mission, only: [:show, :update, :destroy]
  before_action :authenticate_with_token!

  # GET /missions
  def index

    @vehicles = Vehicle.do_user(current_user.id)

    vehicles_ids = []

    @vehicles.each do |vehicle|
      vehicles_ids << vehicle.id
    end

    if not vehicles_ids.blank?

      @missions = Mission.dos_vehicles(vehicles_ids)

      if @missions
        render json: @missions, status: 200
      else
        render json: {errors: "nenhuma missão encontrada para os veiculos selecionados"}, status: 201
      end

    else
      render json: {errors: "você não possue nenhum veiculo cadastrado!"}, status: 201
    end

  end

  # GET /missions/1
  def show
    render json: @mission
  end
  
  # PATCH/PUT /missions/1
  def update

    if params['area_mission'].present?

      area_mission_of_params = params['area_mission']
      area_mission = []

      area_mission_of_params.each do |area|
        if area.to_f > 0
          area_mission << area.to_f
        else
          render json: {errors: "por favor você inseriu valores errados na area da missão"}, status: :unprocessable_entity
          return
        end
      end
    end

    @mission.area_mission = area_mission

    if params["name"].present?
      @mission.name = params['name']
    end

    if params['vehicle_id'].present?
      vehicle = Vehicle.find(params[vehicle_id])
      @mission.vehicle_id = vehicle.id
      @mission.faz_copia_vehicle vehicle
    end


    if @mission.update!
       @mission.create_historic current_user, "fez alteração nos dados da missão"
      render json: @mission
    else
      render json: @mission.errors, status: :unprocessable_entity
    end
  end

  # DELETE /missions/1
  def destroy
    @mission.destroy
  end

  # metodos auxiliares 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mission
      @mission = Mission.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def mission_params
      params.require(:mission).permit(:name, :area_mission, :vehicle_id)
    end
end
