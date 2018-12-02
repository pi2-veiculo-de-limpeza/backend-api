class VehiclesController < ApplicationController
  before_action :set_vehicle, only: [:show, :update, :destroy]
  before_action :authenticate_with_token!, only: [:index, :create, :create_mission, :faz_map_reduce]
  before_action :authenticate_with_token_vehicle!, only: [:started_mission, :speed]

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

    @user = current_user
    
    if @user.nil?
      render json: {errors: "você precisa esta logado para realizar o cadastro"}, status: 404
    end
    

    if params["code"] and params["name"] and params["speed"] and @user
      @vehicle = Vehicle.new(code:params['code'], name:params['name'], speed:params["speed"], user_id:@user.id)
    else
      render status: :unprocessable_entity
      return
    end

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
        render json: {errors: "nenhuma missão encontrada para os veiculos selecionados"}, status: 400
      end
    else
      render json: {errors: "selecione o veículo que deseja ver as missões"}, status: 400
    end
  end

  def speed
    if params["speed"]
      vehicle = current_vehicle
      vehicle.speed = params["speed"]
      vehicle.save!
      render json: :created
    else
      render json: {errors: "você precisa enviar a velocidade do veículo"}, status: 400
    end
  end

  def create_mission

    if params['name'].nil?
      render json: {errors: "Nome não deve está em branco!"}, status: :unprocessable_entity
    elsif params['id'].nil?
      render json: {errors: "selecione um veículo para cadastrar essa missão!"}, status: :unprocessable_entity
    elsif params["coordinates"].nil?
      render json: {errors: "você não selecionou a area do mapa"}, status: :unprocessable_entity
    else

      vehicle = Vehicle.find(params['id'])

      if vehicle.nil?
        render json: {errors: "O veículo que você enviou não existe, por favor repita a operação!"}, status: :unprocessable_entity
        return
      end

      coordinates = []
      coordinates << {"latitude": params["coordinates"][0]["latitude"], "longitude": params["coordinates"][0]["longitude"]}
      coordinates << {"latitude": params["coordinates"][1]["latitude"], "longitude": params["coordinates"][1]["longitude"]}
      coordinates << {"latitude": params["coordinates"][2]["latitude"], "longitude": params["coordinates"][2]["longitude"]}
      coordinates << {"latitude": params["coordinates"][3]["latitude"], "longitude": params["coordinates"][3]["longitude"]}

      @mission = Mission.new


      @mission.name = params['name']
      @mission.vehicle_id = vehicle.id
      @mission.coordinates = coordinates
      @mission.faz_copia_vehicle vehicle
    
      if @mission.save
        @mission.create_historic current_user
        @mission.calculator_area_mission
        render json: @mission, status: :created
      else
        render json: @mission.errors, status: :unprocessable_entity
      end
    end
  end

  def started_mission_now
    @missions = Mission.do_vehicle(current_vehicle).em_andamento.first
    render json: @mission.id.to_s, status: 200
    
  end

  def faz_map_reduce
    #byebug
    if params['id'].nil?
      render json: {errors: "você precisa enviar um id de veiculo"}, status: :unprocessable_entity
      return
    else
      @vehicle = Vehicle.find(params['id'])
      if @vehicle.nil?
        render json: {errors: "você precisa enviar um id de veiculo"}, status: :unprocessable_entity
        return
      else
        @missions = Mission.do_vehicle(@vehicle.id)
        if @missions
          @missions.each do |mission|
            if mission.area_mission.nil?
              mission.area_mission = [120, 15, 8]
              mission.save!
            end
            total_por_mission = [1, 2, 3, 4, 5]
            total_por_mission.each do |index|
              monitory = MonitoryWeight.create(measure_value: index + 3, mission: mission, vehicle: @vehicle, time_measuring: Time.now)
              monitory.save!
              monitory2 = MonitoryVolume.create(measure_value: index + 3, mission: mission, vehicle: @vehicle, time_measuring: Time.now)
              monitory2.save!
              end
          end
          missions_ids = @missions.pluck(:id)
          @monitory = Monitory.das_missions(missions_ids)
          etl_vehicle = Mission.estatisticas_raw_vehicle(@missions, @vehicle)
          render json: etl_vehicle, status: 200
        end
      end
    end
  end

  # refresh veiculo in map
  #def vehicle_map
  #  @mission = params["id"]
  #  position_latitude = @mission.position_latitude
  #  position_longetude = @mission.position_longetude
  #  position = {"latitude": position_latitude, "longetude": position_longetude}
  #  render json position, status: :200
  #end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def vehicle_params
      params.require(:vehicle).permit(:code, :name, :speed, :user_id)
    end


end
