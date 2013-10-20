class FundamentalsController < ApplicationController
  def new
  end

  def create
    date = Date.civil(params[:fundamental]["date(1i)"].to_i, params[:fundamental]["date(2i)"].to_i, params[:fundamental]["date(3i)"].to_i)
    @stock = Stock.find(params[:stock_id])
    @fundamental = @stock.fundamentals.new( :date => date,
					:symbol => @stock.symbol,
					:eps => params[:fundamental][:eps],
					:div => params[:fundamental][:div],
					:pe => params[:fundamental][:pe],
					:pe_high => params[:fundamental][:pe_high],
					:pe_low => params[:fundamental][:pe_low],
					:roe => params[:fundamental][:roe],
					:roa => params[:fundamental][:roa],
					:mkt_cap => params[:fundamental][:mkt_cap],
					:shrs_out => params[:fundamental][:shrs_out],
                                        :stock_id => params[:stock_id]
                                        )

    @fundamental.save
    redirect_to @stock
  end

  def edit
    @fundamental = Fundamental.find(params[:id])
  end

  def update
    @fundamental = Fundamental.find(params[:id])
    @stock = @fundamental.stock

    if @fundamental.update(params[:fundamental].permit( :date, :eps, :div, :pe, :pe_high, :pe_low, :roe, :roa, :mkt_cap, :shrs_out ) )
      redirect_to @stock
    else
      render 'edit'
    end
  end

  def destroy
    @fundamental = Fundamental.find(params[:id])
    @stock = @fundamental.stock
    @fundamental.destroy
    redirect_to @stock
  end

  def show
    @fundamental = Fundamental.find(params[:id])
  end

  def index
    @fundamentals = Fundamental.all
  end

  private
    def fundamental_params
      params.require(:fundamental).permit(:date, :symbol)
    end
end
