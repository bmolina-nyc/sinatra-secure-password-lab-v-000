require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do

    if params[:username].empty? || params[:password].empty?
      redirect "/failure"
    else
      user = User.new(:username => params[:username], :password => params[:password], :balance => params[:balance])
      user.save
      redirect "/login"
    end
  end

  get '/account' do
    @user = User.find(session[:user_id])
    erb :account
  end

  get "/login" do
    erb :login
  end

  post "/login" do
    user = User.find_by(:username => params[:username])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect to "/account"
    else
      redirect to "/failure"
    end
  end

   post '/account' do 
    puts params
    puts current_user.username
    puts current_user.balance
    current_user = User.find(session[:user_id])
    if logged_in? && params["deposit"]
      current_user.balance = current_user.balance += params["deposit"].to_i
    elsif params["withdraw"] && @current_user.balance > params["withdraw"].to_i
      current_user.balance -= params["withdraw"].to_i
    end
    redirect '/account'
  end

  get "/success" do
    if logged_in?
      erb :success
    else
      redirect "/login"
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end

  end

end