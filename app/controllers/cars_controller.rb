class CarsController < ApplicationController
    def cars1
        @cars = Car.find(1)
    end
    def cars2
        @cars = Car.find(2)
    end
    def cars
        @cars = Car.find(params[:id_car])
    end
end
