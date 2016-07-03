class ActionsController < ApplicationController
  attr_accessor :actions_types_all

  def initialize
    @actions_types_all = ActionsType.all
    super
  end

  def new
    @action = Action.new
  end

  def create
    @action = Action.new(action_params)
    @action.execute
    redirect_to actions_path
  end

  def destroy
    @action = Action.find(params[:id])
    @action.undo

    redirect_to actions_path
  end

  def show
    @action = Action.find(params[:id])
  end

  def index
    @actions = Action.all
    @actions = @actions.sort { |a,b| b.created_at <=> a.created_at }
  end

  private
    def action_params
      params.require(:foo).permit(:date, :actions_type_id, :description, :value1, :value2, :value3, :value4, :value5, :symbol)
    end

end
