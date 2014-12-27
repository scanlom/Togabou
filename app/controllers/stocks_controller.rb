require 'assets.rb'

class StocksController < ApplicationController
  attr_accessor :assets

  def initialize
    @assets = Assets.new
    super
  end

  def portfolio_constituents( portfolio_id )
    ret = Constituent.where( sprintf( "portfolio_id = %d and model > 0", portfolio_id ) )
    ret.sort! { |a,b| [ b.value.to_f ] <=> [ a.value.to_f ] }
  end

  def portfolio_stocks( portfolio_id )
    portfolio_constituents( portfolio_id ).map!{ |constituent| constituent.stock }
  end

  def watch_stocks( portfolio_id )
    ret = Stock.where("model >= 0") - portfolio_stocks( portfolio_id )
    ret.sort! { |a,b| [ b.five_year_cagr.to_f ] <=> [ a.five_year_cagr.to_f ] }
  end

  def monitor_stocks
    ret = Stock.where( "model < 0" )
    ret.sort! { |a,b| [ a.id.to_f ] <=> [ b.id.to_f ] }
  end

  def new
  end

  def create
    @stock = Stock.new(params[:stock].permit(:symbol, :eps, :div, :growth, :pe_terminal, :payout, :book, :roe, :model))

    @stock.save
    redirect_to @stock
  end

  def index
    @stocks = Stock.all
  end

  def show
    @stock = Stock.find(params[:id])
  end

  def edit
    @stock = Stock.find(params[:id])
  end

  def update
    @stock = Stock.find(params[:id])

    if @stock.update(params[:stock].permit(:eps, :div, :growth, :pe_terminal, :payout, :book, :roe, :price, :model ) )
      redirect_to @stock
    else
      render 'edit'
    end
  end

  def portfolio_total( portfolio_id )
    self.assets.portfolio_internal( portfolio_id ).total
  end

  def portfolio_total_percent( portfolio_id )
    self.assets.portfolio_internal( portfolio_id ).total.to_f / self.assets.roe_total.to_f
  end

  def portfolio_cash( portfolio_id )
    self.assets.portfolio_internal( portfolio_id ).cash
  end

  def portfolio_cash_percent( portfolio_id )
    self.assets.portfolio_internal( portfolio_id ).cash.to_f / self.assets.portfolio_internal( portfolio_id ).total.to_f
  end

  def portfolio_check( portfolio_id )
    ( self.portfolio_constituents( portfolio_id ).inject(0.0){ |sum,x| sum + x.value.to_f } + portfolio_cash( portfolio_id ).to_f ) / portfolio_total( portfolio_id ).to_f
  end

  def portfolio_model_check( portfolio_id )
    self.portfolio_constituents( portfolio_id ).inject(0.0){ |sum,x| sum + x.model.to_f }
  end

  def portfolio_eps_wtd_total( portfolio_id )
    self.portfolio_constituents( portfolio_id ).inject(0.0){ |sum,x| sum + x.eps_yield_wtd.to_f }
  end

  def portfolio_div_wtd_total( portfolio_id )
    self.portfolio_constituents( portfolio_id ).inject(0.0){ |sum,x| sum + x.div_yield_wtd.to_f }
  end

  private
    def stock_params
      params.require(:stock).permit(:symbol, :eps, :div, :growth, :pe_terminal, :payout, :book, :roe, :model)
    end
end
