class SessionsController < ApplicationController
  include SessionsHelper

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    @flag = 1
    if user && user.authenticate(params[:session][:password])
      log_in user
      if user.admin
        @flag = 0
      end
      params[:session][:remember_me] == '1' ? remember_user(user) : forget_user(user)
      flash= {:info => "欢迎回来: #{user.name} :)"}
    else
      flash= {:danger => '账号或密码错误'}
    end
    if(@flag==0)
      redirect_to root_path, :flash => flash
    else 
      redirect_to courses_path, :flash => flash
    end
  end

  def new
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

end
