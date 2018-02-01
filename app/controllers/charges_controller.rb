class ChargesController < ApplicationController
  layout 'application'
  before_action :check_password, only: [:create]
  before_action :is_mine, only: [:update_membership]
  def new
    @amount = 2999
  end
  def renew_membership
    @amount = 2999
  end
  def is_mine
    @member = Member.all.where(email: params[:stripeEmail]).first
    if @member != nil
      if @member.password == Digest::SHA384.hexdigest(params[:password]+@member.salt)

      else
        redirect_to "/renew_membership", alert: "Incorrect password cancelled payment."
      end
    else
      redirect_to "/renew_membership", alert: "Member does not exist cancelled payment."
    end
  end
  def update_membership
    # Amount in cents
    @amount = 2999
    #Creating a stripe customer
    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :source  => params[:stripeToken]
    )
    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => 'Fresh 2U Plus Yearly Membership Renewal',
      :currency    => 'usd'
    )
    @member.update_attribute("transaction_token",params[:stripeToken])
    redirect_to "/check_membership?member=#{@member.id}"
  rescue Stripe::CardError => e
    redirect_to "/renew_membership", alert: "Error processing payment."
  end
  def check_membership
    @member = Member.all.where(email: params[:member]).first
    if @member != nil
      time = @member.created_at
      elapsed_time = Time.now - time
      @time_left = 360 - (elapsed_time.to_f/(1000*60*60*24)).to_i
    else
      @member = nil
    end
  end
  def create
    # Amount in cents
    @amount = 2999
    #Creating a stripe customer
    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :source  => params[:stripeToken]
    )
    #Hashing and salting password with a SHA3 hasing algorithim
    salt = (0...80).map { (65 + rand(26)).chr }.join
    hash = Digest::SHA384.hexdigest(params[:password]+salt)
    @member = Member.create(email: params[:stripeEmail],password: hash,salt: salt, promo_code: ENV['PROMO_CODE'],transaction_token: params[:stripeToken])
    #Charging the stripe customer
    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => 'Fresh 2U Plus Yearly Membership',
      :currency    => 'usd'
    )
    if @member.save
      @promo_code = @member.promo_code
      MemberMailer.welcome_email(@member.id).deliver
    end
  rescue Stripe::CardError => e
    redirect_to new_charge_path, alert: "Error processing payment."
  end
  def check_password
    if params[:password] != nil and params[:confirm] != nil
      if params[:password] == params[:confirm]
        if params[:password].length < 6
          redirect_to new_charge_path, alert: "Password must be atleast six characters long payment cancelled."
        else
          found = false
          Member.all.each do |m|
            if m.email == params[:stripeEmail]
              found = true
            end
          end
          if found
            redirect_to new_charge_path, alert: "Email already taken payment cancelled."
          end
        end
      else
        flash[:error] = "Both passwords must match payment cancelled."
        redirect_to new_charge_path, alert: "Both passwords must match payment cancelled."
      end
    else
      flash[:error] = "Must fill out all fields payment cancelled."
      redirect_to new_charge_path, alert: "You must fill out all fields payment cancelled."
    end
  end
end
