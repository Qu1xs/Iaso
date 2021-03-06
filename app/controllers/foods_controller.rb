class FoodsController < ApplicationController

  before_action :require_login
  before_action :find_foods, only: [:show, :edit, :update, :destroy]
  before_action :redirect_if_not_owner, only: [:edit, :update, :destroy]


  def new
    if params[:meal_id] && @meal = Meal.find_by_id(params[:meal_id])
        @food = @meal.foods.build
        @foodlog = @food.foodlogs.build
    else
        @food = Food.new
    end
  end

  def create
    @meal = Meal.find_by_id(params[:meal_id])
    food = current_user.foods.build(food_params)

    if food.valid?
      food.save
      if params[:meal_id] 
        redirect_to meal_path(@meal)
      else
        redirect_to food_path(food)
      end
    else
      @meal = Meal.find_by_id(params[:meal_id])
      @food = Food.find_by_id(params[:food_id])
      render :new
    end
  end
  
  def index
    if params[:name] 
      @foods = Food.all.search(params[:name])
    else
      @foods = Food.all
    end

  end

  def show
    @food = Food.find(params[:id])
  end

  def edit
    @foodlog = @food.foodlogs.build
    @food = current_user.foods.find_by_id(params[:id])
  end

  def update
    @food = current_user.foods.find(params[:id])
    @food.update(food_params)
    if params[:meal_id] && @meal = Meal.find_by_id(params[:meal_id])
      redirect_to meal_path(@meal)
    else
      redirect_to food_path(@food)
    end 
  end

  def destroy
    @food = current_user.foods.find_by_id(params[:id])
    # superpower, scope to admin only
    Foodlog.find_by(food_id: food.id).destroy
    @food.destroy
    
    redirect_to foods_path
  end

  
  private

  def food_params
    params.require(:food).permit(
      :name, :category, :carbs, :fats, :proteins, :calories, 
      foodlogs_attributes: [:quantity, :meal_id, :food_id])
  end

  def find_foods
    @food = current_user.foods.find_by_id(params[:id])
  end

  def redirect_if_not_owner
    if @food.user != current_user
      redirect_to user_path(current_user), alert: "You do not have permission to edit this"
    end
  end

end