class MatchesController < ApplicationController
  before_action :set_match, only: %i[ show edit update destroy ]

  # GET /matches or /matches.json
  def index
    if params[:status] == "completed"
      @matches = Match.where(status_id: :completed).order(:match_purse)
    else
      @matches = Match.where(status_id: :pending).order(:match_purse)
    end
  end

  # GET /matches/1 or /matches/1.json
  def show
  end

  # GET /matches/new
  def new
    @match = Match.new
    @match.fighter_1 = Fighter.find(params[:fighter_1_id]) if params[:fighter_1_id].present?
    @match.fighter_2 = Fighter.find(params[:fighter_2_id]) if params[:fighter_2_id].present?
    if params[:weight_class_id].present?
      @fighters = Fighter.where(weight_class_id: params[:weight_class_id]).order(:name)
    else
      @fighters = Fighter.all.order(:name)
    end
    @weight_classes = WeightClass.all
  end

  # GET /matches/1/fight
  def fight
    @match = Match.find(params[:id])
  end

  # GET /matches/1/edit
  def edit
    @match = Match.find(params[:id])
    @fighters = Fighter.all.order(:name)
    @weight_classes = WeightClass.all
  end

  # POST /matches or /matches.json
  def create
    params[:match][:status_id] = params[:match][:status_id].to_i if params[:match][:status_id].present?
    puts params[:match][:status_id]
    @match = Match.new(match_params)
    @weight_classes = WeightClass.all
    @fighters = Fighter.all

    respond_to do |format|
      if @match.save
        format.html { redirect_to matches_url, notice: "Match was successfully created." }
        format.json { render :show, status: :created, location: @match }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matches/1 or /matches/1.json
  def update
    params[:match][:status_id] = params[:match][:status_id].to_i if params[:match][:status_id].present?
    puts params[:match][:status_id]

    respond_to do |format|
      if @match.update(match_params)
        format.html { redirect_to matches_url, notice: "Match was successfully updated." }
        format.json { render :show, status: :ok, location: @match }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matches/1 or /matches/1.json
  def destroy
    @match.destroy

    respond_to do |format|
      format.html { redirect_to matches_url, notice: "Match was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def match_params
      params.require(:match).permit(:max_rounds, :fighter_1_id, :fighter_2_id, :status_id, :winner_id, :result_id, :weight_class_id)
    end
end
