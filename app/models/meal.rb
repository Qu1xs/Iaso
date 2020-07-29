class Meal < ApplicationRecord
    # t.string :name

    belongs_to :user
    has_many :foodlogs
    has_many :foods, through: :foodlogs

    validates :name, presence: true

    scope :order_by_calories, -> { order(price: :desc)}
    scope :order_by_carbs, -> { order(carbs: :desc)}

    # extend Search::ClassMethods

    def foodlogs_attributes=(foodlogs_attributes)
        foodlogs_attributes.values.each do |foodlog_attributes| 
            next unless foodlog_attributes[:quantity].present?
            foodlog = Foodlog.find_or_create_by(foodlog_attributes)
            self.foodlogs << foodlog
        end	  
    end

    def foods_attributes=(foods_attributes)
        foods_attributes.values.each do |food_attributes| 
            # {"quantity"=>"1", "food_id"=>"8"}
            next unless food_attributes.values.all? { |v| v.present? }
            food = Food.find_or_create_by(food_attributes)
            self.foods << food
        end	  
    end


    def todays_meals
        Meal.all.today
    end

    def self.today 
        where("created_at >= ?", Time.now.beginning_of_day) 
    end

    # Today.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)

    # Author.joins(:articles).where(articles: { author: author })

    # def calculate_macros(macro)
    #     count = 0
    #     self.foodlogs.each do |foodlog|
    #         count += foodlog.quantity * foodlog.food.send(macro)
    #     end
    #     count
    # end


    def calculate_macros(macro = :calories)
        count = 0
        self.foodlogs.each do |foodlog|
            item = foodlog.quantity * foodlog.food.send(macro)
            count += item
        end
        count
    end

    #view example
    # @meal.order_by_calories.order_by_carbs(15)
end