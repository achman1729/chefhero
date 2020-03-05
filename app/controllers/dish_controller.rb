class DishController < ApplicationController

    # simple instance of dish model for use in create method
    def new
        @dish = Dish.new
    end

    # index method for dishes
    def index
        # filter/sort depending on search paramaters passed (or not)
        filter = Dish.search(params[:search])
        @dishes = filter.where(available: true)
        if params[:sort] == "ordered"
            @dishes = @dishes.sort_by_orders
        end
        if params[:sort] == "newest"
            @dishes = @dishes.sort_by_newest
        end

    end

    # post method for creating a dish
    def create
        @dish = current_user.dishes.create(dish_params)
        @dish.image.attach(params[:dish][:image])
        @dish.available = true
        if @dish.valid? && @dish.save
            redirect_to manager_path(:option => "Manager")
        end
    end

    # instance method for displaying dish on show route
    def show
        @dish = Dish.find(params[:id])
    end

    # method for deleting a dish
    def destroy
        dish = Dish.find(params[:id])
        dish.delete
        flash[:alert] = "#{dish.name} has been deleted successfully."
        redirect_to manager_path(:option => "Manager")
    end
    
    # method for listing a dish - through changing availability attribute boolean
    def list
        dish = Dish.find(params[:id])
        dish.available = true
        dish.save
        flash[:alert] = "#{dish.name} has been successfully listed on the market for selling"
        redirect_to manager_path(:option => "Manager")
    end

    # as above but for delisting
    def unlist
        dish = Dish.find(params[:id])
        dish.available = false
        dish.save
        flash[:alert] = "#{dish.name} has been succesfully unlisted off the market"
        redirect_to manager_path(:option => "Manager")
    end

    # instance call to display dish details for editing
    def edit
        @dish = Dish.find(params[:id])
        render layout: "dashboard"
    end

    # update method for any changes to dish details as above
    def update
        dish = Dish.find(params[:id])
        dish.update(dish_params)
        if dish.valid? && dish.save
            redirect_to manager_path(:option => "Manager")
        else
            flash[:alert] = "Sorry something went wrong, could not update your dish at this time."
            render "edit"
        end
    end


    private
    def dish_params
        params.require(:dish).permit(:name, :category, :about, :price, :image, :ingredients)
    end

end
