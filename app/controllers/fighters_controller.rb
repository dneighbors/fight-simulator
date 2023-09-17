class FightersController < ApplicationController
  before_action :set_fighter, only: %i[ show edit update destroy ]

  # GET /fighters or /fighters.json
  def index
    if params[:current_champs] == 'true'
      @fighters = Fighter.where(id: Title.where(lost_at: nil).select(:fighter_id)).order(:weight_class_id, :name)
    elsif params[:top_money] == 'true'
      @fighters = Fighter.all.sort_by { |fighter| -fighter.total_winnings }.take(10)
    else
      @fighters = Fighter.order(:weight_class_id, :name)
    end
  end

  # GET /fighters/1 or /fighters/1.json
  def show
  end

  # GET /fighters/new
  def new
    @fighter = Fighter.new
    @fighter.weight = (WeightClass.find(params[:weight_class_id]).max_weight - 2) if params[:weight_class_id].present?
    @weight_classes = WeightClass.all
  end

  # GET /fighters/1/edit
  def edit
    @weight_classes = WeightClass.all
  end

  # POST /fighters or /fighters.json
  def create
    @fighter = Fighter.new(fighter_params)

    respond_to do |format|
      if @fighter.save
        format.html { redirect_to fighter_url(@fighter), notice: "Fighter was successfully created." }
        format.json { render :show, status: :created, location: @fighter }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @fighter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fighters/1 or /fighters/1.json
  def update
    respond_to do |format|
      if @fighter.update(fighter_params)
        format.html { redirect_to fighters_url, notice: "Fighter was successfully updated." }
        format.json { render :show, status: :ok, location: @fighter }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @fighter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fighters/1 or /fighters/1.json
  def destroy
    @fighter.destroy

    respond_to do |format|
      format.html { redirect_to fighters_url, notice: "Fighter was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fighter
      @fighter = Fighter.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def fighter_params
      params.require(:fighter).permit(:name, :nickname, :birthplace, :punch, :strength, :speed, :dexterity, :base_endurance, :endurance, :weight, :weight_class_id)
    end
end
