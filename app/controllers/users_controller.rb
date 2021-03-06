class UsersController < ApplicationController

    before_action :permission_required, only: [:show, :edit, :update, :destroy]

    def new
        @user = User.new
    end

    def create
        if user = User.create(user_params)
            session[:user_id] = user.id

        # respond_to do |format|
        #     if @user.save
        #       # Tell the UserMailer to send a welcome email after save
        #       UserMailer.with(user: @user).welcome_email.deliver_later
       
        #       format.html { redirect_to(@user, notice: 'User was successfully created.') }
        #       format.json { render json: @user, status: :created, location: @user }
        #     else
        #       format.html { render action: 'new' }
        #       format.json { render json: @user.errors, status: :unprocessable_entity }
        #     end
        #   end

            redirect_to user_path(user)
        else
            render :new #> render to show errors
            # render new_user_path
        end


    end

    def show
        @user = User.find_by_id(params[:id])
        @meals = current_user.meals.includes(foodlogs:[:foods])
    end

    def edit
        @user = User.find_by_id(params[:id])
    end

    def update
        current_user.update(user_params)
        redirect_to user_path(current_user)
        flash[:message] = "Successfully updated user."
    end

    def destroy
		# current_user.meals.try.delete
		# current_user.foodlogs.try.delete
		current_user.destroy
		redirect_to root_path
    end


    private

    def user_params
        params.require(:user).permit(:name, :password, :password_confirmation, :email, :height, :weight, :uid, :provider)
    end

    def require_login
        return head(:forbidden) unless session.include? :user_id
    end

end