require 'http'
require 'json'
class Stock < ActiveRecord::Base
    has_many :user_stocks
    has_many :stock_values
    has_many :users, :through => :user_stocks

    def self.fetch(shortName)
        reply = HTTP.get("http://finance.google.com/finance/info?client=ig&q=" + shortName)
        if reply.code == 200
            stock = Stock.new(shortName: JSON.parse(reply.to_s()[/\[([\s\S]*)\]/,1])['t'])
            if stock.save
                return stock
            else
                return nil
            end
        else
            return nil
        end
    end
end
