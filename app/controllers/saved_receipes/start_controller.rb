module SavedReceipes
  class StartController < ApplicationController
    def new
      @start_form = StartForm.new
    end

    def create
    end
  end
end
