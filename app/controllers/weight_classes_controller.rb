class WeightClassesController < ApplicationController
  before_action :set_weight_class, only: %i[ show edit update destroy ]

  # GET /weight_classes or /weight_classes.json
  def index
    @weight_classes = WeightClass.all
  end

  # GET /weight_classes/1 or /weight_classes/1.json
  def show
  end

  # GET /weight_classes/new
  def new
    @weight_class = WeightClass.new
  end

  # GET /weight_classes/1/edit
  def edit
  end

  # POST /weight_classes or /weight_classes.json
  def create
    @weight_class = WeightClass.new(weight_class_params)

    respond_to do |format|
      if @weight_class.save
        format.html { redirect_to weight_class_url(@weight_class), notice: "Weight class was successfully created." }
        format.json { render :show, status: :created, location: @weight_class }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @weight_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /weight_classes/1 or /weight_classes/1.json
  def update
    respond_to do |format|
      if @weight_class.update(weight_class_params)
        format.html { redirect_to weight_class_url(@weight_class), notice: "Weight class was successfully updated." }
        format.json { render :show, status: :ok, location: @weight_class }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @weight_class.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /weight_classes/1 or /weight_classes/1.json
  def destroy
    @weight_class.destroy

    respond_to do |format|
      format.html { redirect_to weight_classes_url, notice: "Weight class was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_weight_class
      @weight_class = WeightClass.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def weight_class_params
      params.require(:weight_class).permit(:name, :max_weight)
    end
end
