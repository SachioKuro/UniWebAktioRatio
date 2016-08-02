class UserStock < ActiveRecord::Base
    belongs_to :stocks
    belongs_to :users
end
