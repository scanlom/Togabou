class ResearchesController < ApplicationController
  def new
  end

  def create
    date = Date.civil(params[:research]["date(1i)"].to_i, params[:research]["date(2i)"].to_i, params[:research]["date(3i)"].to_i)
    eps_yr1_date = Date.civil(params[:research]["eps_yr1_date(1i)"].to_i, params[:research]["eps_yr1_date(2i)"].to_i, params[:research]["eps_yr1_date(3i)"].to_i)
    eps_yr2_date = Date.civil(params[:research]["eps_yr2_date(1i)"].to_i, params[:research]["eps_yr2_date(2i)"].to_i, params[:research]["eps_yr2_date(3i)"].to_i)

    @stock = Stock.find(params[:stock_id])
    @research = @stock.researches.new( :symbol => @stock.symbol,
					:date => date, 
					:eps => @stock.eps, 
					:div => @stock.div, 
					:growth => @stock.growth, 
					:pe_terminal => @stock.pe_terminal, 
					:payout => @stock.payout, 
					:book => @stock.book, 
					:roe => @stock.roe, 
					:price => @stock.price, 
					:div_plus_growth => @stock.div_plus_growth, 
					:eps_yield => @stock.eps_yield, 
					:div_yield => @stock.div_yield, 
					:five_year_cagr => @stock.five_year_cagr, 
					:ten_year_cagr => @stock.ten_year_cagr, 
					:five_year_croe => @stock.five_year_croe, 
					:ten_year_croe => @stock.ten_year_croe, 
					:eps_yr1_date => eps_yr1_date, 
					:eps_yr1 => params[:research][:eps_yr1],
					:eps_yr2_date => eps_yr2_date, 
					:eps_yr2 => params[:research][:eps_yr2],
					:comment => params[:research][:comment], 
					:stock_id => params[:stock_id]
					)

    @research.save
    redirect_to @stock
  end

  def edit
    @research = Research.find(params[:id])
  end

  def update
    @research = Research.find(params[:id])
    @stock = @research.stock
    
    if @research.update(params[:research].permit(:date, :eps_yr1_date, :eps_yr1, :eps_yr2_date, :eps_yr2, :comment ) )
      redirect_to @stock
    else
      render 'edit'
    end
  end

  def destroy
    @research = Research.find(params[:id])
    @stock = @research.stock
    @research.destroy
    redirect_to @stock
  end

  def show
    @research = Research.find(params[:id])
  end

  def index
    @researches = Research.all
  end

  private
    def research_params
      params.require(:research).permit(:symbol, :comment)
    end
end
