class User < ActiveRecord::Base
    has_many :user_stocks
    has_many :stocks, :through => :user_stocks

    has_secure_password

    validates :password, confirmation: true, length: { minimum: 8 }
    validates :password_confirmation, presence: true

    validates :username, presence: true, length: { minimum: 3}, uniqueness: { case_sensitive: false }

    def self.authenticate(username, password)
        user = find_by_username(username)
        if user && user.password_digest == BCrypt::Engine.hash_secret(password)
            user
        else
            nil
        end
    end
end
