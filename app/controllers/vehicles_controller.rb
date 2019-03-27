class VehiclesController < ApplicationController
  before_action :find_vehicle, only: %i[show update edit destroy]
  skip_before_action :authenticate_user!, only: %i[index show new create]
  after_create :send_email_after_create

  def index
    @vehicles = Vehicle.all
  end

  def show
  end

  def new
    @vehicle = Vehicle.new
  end

  def create
    @vehicle = Vehicle.new(vehicle_params)
    @user = User.create(first_name: params[:first_name], last_name: params[:last_name], email: params[:email], password: '123456')
    @vehicle.user = @user
    if @vehicle.save
      params[:vehicle][:photos][:url]&.each do |url|
        @vehicle.photos.create(url: url)
      end
      redirect_to vehicle_path(@vehicle)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @vehicle.update(vehicle_params)
    if @vehicle.save
      redirect_to vehicle_path(@vehicle)
    else
      render :edit
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to root_path
  end

  private

  def find_vehicle
    @vehicle = Vehicle.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(:make, :year, :owner, :color, :inspection_card, :diesel, :property_insurance, :insurance)
  end

  def send_email_after_create
    VehicleMailer.new_vehicle_created(self, user).deliver_now
  end
end
