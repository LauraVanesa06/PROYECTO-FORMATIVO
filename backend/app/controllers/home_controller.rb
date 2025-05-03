class HomeController < ApplicationController
    skip_before_action :authenticate_user!, onli: [:index]
    def index
    end
end
