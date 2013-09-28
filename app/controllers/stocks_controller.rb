require 'assets.rb'

class StocksController < ApplicationController
  attr_accessor :assets
  attr_accessor :portfolio
  attr_accessor :watch_list

  def initialize
      @assets = Assets.new
  end

  def lazy_initialize
    if @portfolio == nil
      @portfolio = Stock.where("model > 0")
      @portfolio.sort! { |a,b| [ b.value.to_f ] <=> [ a.value.to_f ] }
      @watch_list = Stock.where("model <= 0")
      @watch_list.sort! { |a,b| [ b.five_year_cagr.to_f ] <=> [ a.five_year_cagr.to_f ] }
    end
  end

  def portfolio
    lazy_initialize
    @portfolio
  end

  def watch_list
    lazy_initialize
    @watch_list
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

    if @stock.update(params[:stock].permit(:eps, :div, :growth, :pe_terminal, :payout, :book, :roe, :price ) )
      redirect_to @stock
    else
      render 'edit'
    end
  end

  def portfolio_total
    lazy_initialize
    self.assets.portfolio.total
  end

  def portfolio_total_percent
    lazy_initialize
    self.assets.portfolio.total.to_f / self.assets.roe_total.to_f
  end

  def portfolio_cash
    lazy_initialize
    self.assets.portfolio.cash
  end

  def portfolio_cash_percent
    lazy_initialize
    self.assets.portfolio.cash.to_f / self.assets.portfolio.total.to_f
  end

  def portfolio_check
    lazy_initialize
    ( self.portfolio.inject(0.0){ |sum,x| sum + x.value.to_f } + portfolio_cash.to_f ) / portfolio_total.to_f
  end

  def portfolio_eps_wtd_total
    lazy_initialize
    self.portfolio.inject(0.0){ |sum,x| sum + x.eps_yield_wtd.to_f }
  end

  def portfolio_div_wtd_total
    lazy_initialize
    self.portfolio.inject(0.0){ |sum,x| sum + x.div_yield_wtd.to_f }
  end
  
  private
    def stock_params
      params.require(:stock).permit(:symbol, :eps, :div, :growth, :pe_terminal, :payout, :book, :roe, :model)
    end 
end
