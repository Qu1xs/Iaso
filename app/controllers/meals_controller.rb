class MealsController < ApplicationController

  before_action :require_login
  before_action :find_meals, only: [:edit, :update, :destroy]
  before_action :redirect_if_not_owner,  only: [:update, :destroy]


  def new
    if params[:food_id] && @food = Food.find_by_id(params[:food_id])
      @meal = @food.meals.build
      @foodlog = @food.foodlogs.build
    else
      @meal = Meal.new
    end
  end

  def create
    meal = current_user.meals.build(meal_params)
    if meal.valid?
      meal.save

      redirect_to meal_path(meal)
    else
      @meal = Meal.new
      render :new
    end
  end

  def index
    #nested route
    if params[:user_id] && @user = User.find_by_id(params[:user_id])
        @meals = @user.meals
    else
      @meals = current_user.meals
      # @meals = Meal.all 
    end
  end

  def show
    @meal = Meal.find_by_id(params[:id])
    # @meal = @foodlog.meal
    @foodlog = @meal.foodlogs.find_by_id(params[:id])
    @foods = Food.all.order_by_name
    @food = @meal.foods.build
    #don't need
    @foodlogs = @meal.foodlogs
  end

  def edit
    @meal = current_user.meals.find_by_id(params[:id])
  end

  def update
    @meal.update(meal_params)
    
    redirect_to meal_path(@meal)
  end

  def destroy
    @meal.foodlogs.destroy
    @meal.destroy
    redirect_to meals_path
  end

    
  private

  def meal_params
    params.require(:meal).permit(
      :name, 
      # foods_attributes: [:name, :category, :carbs, :fats, :proteins, :calories], 
      foodlogs_attributes: [:quantity, :meal_id, :food_id])
  end

  def find_meals
    @meal = current_user.meals.find_by_id(params[:id])
  end

  def redirect_if_not_owner
      if @meal.user != current_user
          redirect_to user_path(current_user), alert: "You can't edit this meal!"
      end
  end

end
