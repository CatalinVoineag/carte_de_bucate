class ReceipesController < ApplicationController
  before_action :set_receipe, only: %i[ show edit update destroy ]

  # GET /receipes or /receipes.json
  def index
    filter_form = ReceipeFilterForm.new(params:, receipe_class: GlobalReceipe)
    @receipes = filter_form.filtered_receipes
    @receipe_name_query = filter_form.receipe_name.presence
    @ingredients_query = filter_form.ingredients.presence
  end

  # GET /receipes/1 or /receipes/1.json
  def show
  end

  # GET /receipes/new
  def new
    @receipe = GlobalReceipe.new
    @receipe.receipe_ingredients.build.build_ingredient
  end

  # GET /receipes/1/edit
  def edit
  end

  # POST /receipes or /receipes.json
  def create
    @receipe = GlobalReceipe.new(receipe_params)

    respond_to do |format|
      if @receipe.save
        format.html { redirect_to receipe_path(@receipe), notice: "Receipe was successfully created." }
        format.json { render :show, status: :created, location: @receipe }
      else
        @receipe.receipe_ingredients.each do |receipe_ingredient|
          receipe_ingredient.build_ingredient if receipe_ingredient.ingredient.blank?
        end

        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @receipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /receipes/1 or /receipes/1.json
  def update
    respond_to do |format|
      if @receipe.update(receipe_params)
        format.html { redirect_to receipe_path(@receipe), notice: "Receipe was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @receipe }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @receipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipes/1 or /receipes/1.json
  def destroy
    @receipe.destroy!

    respond_to do |format|
      format.html { redirect_to receipes_path, notice: "Receipe was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_receipe
    @receipe = GlobalReceipe.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def receipe_params
    params.expect(
      receipe: [
        :name,
        :description,
        :instructions,
        receipe_ingredients_attributes: [ [
          :id,
          :quantity,
          :grams,
          :_destroy,
          ingredient_attributes: [ :id, :name ]
        ] ]
      ],
    )
  end
end
