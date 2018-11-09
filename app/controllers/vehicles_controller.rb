class VehiclesController < ApplicationController
  before_action :set_vehicle, only: [:show, :update, :destroy]
  before_action :authenticate_with_token!, only: [:index]

  # GET /vehicles
  def index

    @vehicles = Vehicle.do_user(current_user.id)

    render json: @vehicles
  end

  # GET /vehicles/1
  def show
    render json: @vehicle
  end

  # POST /vehicles
  def create
    @vehicle = Vehicle.new(vehicle_params)

    if @vehicle.save
      @vehicle.create_historic current_user
      render json: @vehicle, status: :created, location: @vehicle
    else
      render json: @vehicle.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /vehicles/1
  def update
    if @vehicle.update(vehicle_params)
      render json: @vehicle
    else
      render json: @vehicle.errors, status: :unprocessable_entity
    end
  end

  # DELETE /vehicles/1
  def destroy
    @vehicle.destroy
  end

  #outros metodos

  def all_missions_vehicle
    if params['id']
      vehicle_id = params['id']

      @missions = Mission.do_vehicle(vehicle_id)

      if @missions
        render json: @missions, status: 200
      else
        render json: {errors: "nenhuma missão encontrada para os veiculos selecionados"}, status: 201
      end
    else
      render json: {errors: "selecione o veículo que deseja ver as missões"}, status: 201
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def vehicle_params
      params.require(:vehicle).permit(:code, :name, :historic, :speed, :user_id)
    end
end
