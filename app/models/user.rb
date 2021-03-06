class User < ApplicationRecord
    # t.string "name"
    # t.string "password_digest"
    # t.string "email"
    # t.integer "height"
    # t.integer "weight"
    # t.integer "bodyfat"
    # t.integer "calorie_limit"
    # t.string "photo"
    # t.string "uid"
    # t.string "provider"

    has_secure_password

    has_many :meals, dependent: :destroy
    has_many :foodlogs, through: :meals, dependent: :destroy
    has_many :foods

    validates :name, presence: true
    validates :name, uniqueness: true
    
    # validates_length_of :password, within: 4..72

    # validates :name, email, height, weight, presence: true
    validates :email, presence: true, email: true

  

    def self.from_omniauth(auth)
        User.find_or_create_by(uid: auth['uid'], provider: auth['provider']) do |u|
            u.name = auth['info']['name']
            u.email = auth['info']['email']
            u.password = SecureRandom.hex(16) #=> Set temp password
        end
    end

    # {"provider"=>"google_oauth2",
    #     "uid"=>"104405097401751336968",
    #     "info"=>
    #      {"name"=>"Kevin M",
    #       "email"=>"kevinnealmurphy@gmail.com",
    #       "unverified_email"=>"kevinnealmurphy@gmail.com",
    #       "email_verified"=>true,
    #       "first_name"=>"Kevin",
    #       "last_name"=>"M",
    #       "image"=>
    #        "https://lh4.googleusercontent.com/-2XgXgN4XtXI/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuck8WDi83OG_NDFVo7X9EyL02VgdFA/photo.jpg"}

    def todays_meals
        meals.today
    end

    def todays_calories
        mealcount = 0
        todays_meals.each {|meal| mealcount += meal.calculate_macros}
        mealcount
    end

    def todays_macros(macro = :calories)
        mealcount = 0
        todays_meals.each {|meal| mealcount += meal.calculate_macros(macro)}
        mealcount
    end

end