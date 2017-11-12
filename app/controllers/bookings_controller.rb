class BookingsController < ApplicationController
  access user: {except: [:destroy, :new, :create, :indexadmin]}, labor_staff: :all
  skip_before_action :verify_authenticity_token, :only => [:sort]



  def indexadmin
    @bookings = Booking.by_position
    @bookings_pending = Booking.pending
    @bookings_confirmed = Booking.confirmed
    @bookings_claimed = Booking.claimed
    @bookings_unclaimed = Booking.unclaimed
    @bookings_overdue = Booking.overdue
    @bookings_returned = Booking.returned
  end

  def sort
    params[:order].each do |key, value|
      Booking.find(value[:id]).update(position: value[:position])
    end

    render body: nil
  end
  
  def index
    @bookings = current_user.bookings
    @users = User.joins(:bookings).distinct
  end

  def new
    @booking = Booking.new
    session[:booking_id] = @booking.id
  end

  def create
    @booking = current_user.bookings.build(booking_params)

    respond_to do |format|
      if @booking.save!
        format.html { redirect_to bookings_path, notice: 'Booking was successfully submitted.' }
      else
        format.html { render :new }
      end
    end
  end

  def edit
    @booking = Booking.find(params[:id])
    @booking_items = @booking.booking_items
    @labor_item = Equipment.joins(:booking_items)
  end

  def update
    @booking = Booking.find(params[:id])

    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to booking_path, notice: 'Booking was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def show
    @booking = Booking.find(params[:id])
    @booking_items = @booking.booking_items
    @labor_item = Equipment.joins(:booking_items)
  end

  def destroy
    # Look up
    @booking = Booking.find(params[:id])

    # Destroy/Delete the record
    @booking_items = @booking.booking_items
    @booking_items.destroy
    @booking.destroy

    # Redirect
    respond_to do |format|
      format.html { redirect_to booking_path, notice: 'Booking was removed.' }
    end
  end

private
  def booking_params
    params.require(:booking).permit(:pickup_date,
                                    :return_date,
                                    :current_user,
                                    :project_id,
                                    :booking_status_id,
                                    :message
                                    )

  end
private
  def users
    User.joins(:bookings)
  end
end
