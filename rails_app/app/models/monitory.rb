class Monitory
  include Mongoid::Document
  include Mongoid::Timestamps::Short

   field :time_measuring, type: Time, default: nil
   field :measure_value, type: Float, default: nil

   belongs_to :vehicle
   belongs_to :mission

   scope :do_vehicle, ->(vehicle_id) {self.and(:vehicle_id=>vehicle_id)}
   scope :da_mission, ->(mission_id) {self.and(:mission_id=>mission_id)}
   
end
