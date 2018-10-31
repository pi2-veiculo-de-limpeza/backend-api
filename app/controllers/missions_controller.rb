class MissionsController < ApplicationController
  before_action :set_mission, only: [:show, :update, :destroy]
  before_action :authenticate_with_token!

  # GET /missions
  def index
    @missions = Mission.all

    render json: @missions
  end

  # GET /missions/1
  def show
    render json: @mission
  end

  # POST /missions
  def create

    if params['name'].nil?
      render json: {errors: "Nome não deve está em branco!"}, status: :unprocessable_entity
    elsif params['vehicle_id'].nil?
      render json: {errors: "selecione um veículo para executar essa missão!"}, status: :unprocessable_entity
    elsif params['area_mission'].nil?
      render json: {errors: "você deve fornecer a area da missão!"}, status: :unprocessable_entity
    else

      vehicle = Vehicle.find(params['vehicle_id'])

      if vehicle.nil?
        render json: {errors: "O veículo que você enviou não existe, por favor repita a operação!"}, status: :unprocessable_entity
        return
      end

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

      @mission = Mission.new

      @mission.name = params['name']
      @mission.vehicle_id = vehicle.id
      @mission.area_mission = area_mission

      puts area_mission
    
      if @mission.save
        @mission.create_historic current_user
        render json: @mission, status: :created, location: @mission
      else
        render json: @mission.errors, status: :unprocessable_entity
      end
    end

      
  end

  # PATCH/PUT /missions/1
  def update
    if @mission.update(mission_params)
      render json: @mission
    else
      render json: @mission.errors, status: :unprocessable_entity
    end
  end

  # DELETE /missions/1
  def destroy
    @mission.destroy
  end

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
