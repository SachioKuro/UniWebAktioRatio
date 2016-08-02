class UsersController < ApplicationController
    def index
        @is_notif = User.find(session[:user_id]).notification
    end

    def show
        @user = User.find(params[:id])
    end

    def new
        @user = User.new
    end

    def create
        @user = User.new(params.require(:user).permit(:username, :email, :password, :password_confirmation))

        if @user.save
            redirect_to @user
        else
            render 'new'
        end
    end

    def update
        #authorize
        user = User.find(session[:user_id])
        user.update_attribute(:email, params[:email]) if params[:email] != ""
        user.update_attribute(:notification, params[:notification] == "true")

        redirect_to user_path
    end
end
