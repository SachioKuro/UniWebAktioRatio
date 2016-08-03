class UserStocksController < ApplicationController
  before_filter :authorize

  def index
      @portfolio_stocks = UserStock.where(username: @current_user.username).select(:shortName).distinct
      @selected_stocks = params[:stock_selection]
      @selected_stocks ||= []

      update_limits(params[:limit_value], params[:limit]) if request.post?
      fill_limits() if request.post?

      @limit_values = params[:limit_value]
      @limit_flags = params[:limit]
  end

  def new
      @user_stock = UserStock.new
      @stocks_not_in_portfolio = Stock.find_by_sql(['SELECT * FROM "stocks" WHERE
          "shortName" IN (SELECT "shortName" FROM "stocks" except SELECT "shortName"
          FROM "user_stocks" WHERE "username" = ?)', @current_user.username])
  end

  def create
      @user_stock = UserStock.new(params.require(:user_stock).permit!)
      if params[:search] != ""
          if UserStock.where(username: @current_user.username).where(shortName: params[:search]).count > 0
             redirect_to url_for(action: 'new') and return
          end
          @user_stock.shortName = params[:search]
      end
      @user_stock.username = User.find(session[:user_id]).username
      unless Stock.find_by_shortName(@user_stock.shortName)
          if Stock.fetch(params[:search]).nil?
             redirect_to url_for(action: 'new') and return
          end
      end
      if @user_stock.save
          redirect_to '/user_stocks'
      else
          render 'new'
      end
  end


  helper_method :get_values, :selection_changed
  def get_values(stockname)
      values = StockValue.where(shortname: stockname).select(:t, :value).as_json({except: :id})
      chart_values = Hash.new
      for value in values
          chart_values[value['t']] = value['value']
      end
      return chart_values
  end

  protected
  def update_limits(limit_values, limit_flags)
      @id_pr ||= 0
      connection = ActiveRecord::Base.connection.raw_connection
      if limit_values != nil
          limit_values.each do |k,v|
              if v["min"] != ""
                  connection.exec_params('update "user_stocks" set "bLimit"=$1 where "username"=$2 and "shortName"=$3', [v["min"].to_f, @current_user.username, k])
              else
                  connection.exec_params('update "user_stocks" set "bLimit"=$1 where "username"=$2 and "shortName"=$3', [nil, @current_user.username, k])
              end
              if v["max"] != ""
                  connection.exec_params('update "user_stocks" set "tLimit"=$1 where "username"=$2 and "shortName"=$3', [v["max"].to_f, @current_user.username, k])
              else
                  connection.exec_params('update "user_stocks" set "tLimit"=$1 where "username"=$2 and "shortName"=$3', [nil, @current_user.username, k])
              end
          end
      end
      if limit_flags != nil
          limit_flags.each do |k,v|
              connection.exec_params('update "user_stocks" set "bActive"=$1 where "username"=$2 and "shortName"=$3', [(v.include? "min"), @current_user.username, k])
              connection.exec_params('update "user_stocks" set "tActive"=$1 where "username"=$2 and "shortName"=$3', [(v.include? "max"), @current_user.username, k])
          end
      end
  end

  def fill_limits
      userStocks = UserStock.where(username: @current_user.username)
      if userStocks != nil
          params[:limit_value] = {}
          params[:limit] = {}
          userStocks.each do |stock|
              params[:limit_value][stock.shortName] = {}
              params[:limit_value][stock.shortName]["min"] = if stock.bLimit.to_s != ""
                  stock.bLimit.to_s
              else
                  "0.00"
              end
              params[:limit_value][stock.shortName]["max"] = if stock.bLimit.to_s != ""
                  stock.tLimit.to_s
              else
                  "0.00"
              end
              params[:limit][stock.shortName] = []
              params[:limit][stock.shortName].push("min") if stock.bActive
              params[:limit][stock.shortName].push("max") if stock.tActive
          end
      end
  end
end
