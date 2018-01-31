class ChargesController < ApplicationController
  layout 'application'
  before_action :check_password, only: [:create]
  def new
    @amount = 5000
  end

  def create
    # Amount in cents
    @amount = 5000
    #Creating a stripe customer
    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :source  => params[:stripeToken]
    )
    #Hashing and salting password with a SHA3 hasing algorithim
    salt = (0...80).map { (65 + rand(26)).chr }.join
    hash = Digest::SHA384.hexdigest(params[:password]+salt)
    @member = Member.create(email: params[:stripeEmail],password: hash,salt: salt, promo_code: ENV['PROMO_CODE'])
    #Charging the stripe customer
    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => 'Fresh 2U Plus Yearly Membership',
      :currency    => 'usd'
    )
    if @member.save
      @promo_code = @member.promo_code
    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to new_charge_path
  end
  def check_password
    if params[:password] != nil and params[:confirm] != nil
      if params[:password] == params[:confirm]

      else
        flash[:error] = "Both passwords must match."
        redirect_to new_charge_path
      end
    else
      flash[:error] = "Must fill out all fields."
      redirect_to new_charge_path
    end
  end
end
