require 'accounts.rb'
require 'assets.rb'

class PagesController < ApplicationController
  attr_accessor :chart_infos
  
  def initialize
    
    # Get the chart types
    @chart_infos = Array.new
    chart_info = Struct.new( :table, :where, :name )
    conn = ActiveRecord::Base.connection
    
    # index_history chart types
    res = conn.execute( "select type, description from divisors_types order by type asc" )
    res.values().each do |row|
      @chart_infos << chart_info.new( "index_history", sprintf( "type = %d", row[0] ), row[1] )
    end
    
    # portfolio_history chart types
    res = conn.execute( "select distinct symbol, type from portfolio_history order by symbol asc" )
    res.values().each do |row|
      @chart_infos << chart_info.new( "portfolio_history", sprintf( "symbol = '%s' and type = %d", row[0], row[1] ), sprintf( "%s - %s", row[0], row[1] ) )
    end

    # balances_history chart types
    res = conn.execute( "select type, description from balances order by type asc" )
    res.values().each do |row|
      @chart_infos << chart_info.new( "balances_history", sprintf( "type = %d", row[0] ), row[1] )
    end
            
    super
  end
  
  def get_assets( str_date )
    ret = nil
    if str_date == nil or str_date == ""
      ret = Assets.new
    else
      ret = Assets.new( Date.parse( str_date ) )
    end
    ret
  end
  
  def get_accounts( str_date )
    ret = nil
    if str_date == nil or str_date == ""
      ret = Accounts.new
    else
      ret = Accounts.new( Date.parse( str_date ) )
    end
    ret
  end
  
  def get_chart( chart_number )
    if chart_number == nil or chart_number == ""
      chart_number = "1" # The ROE chart
    end
    chart_number = chart_number.to_i
    conn = ActiveRecord::Base.connection
    chart = @chart_infos[ chart_number ]
    data = Array.new
    res = conn.execute( sprintf( "select date, value from %s where %s order by date asc", chart.table, chart.where ) )
    res.values().each do |row|
      point = Array.new
      point << DateTime.parse(row[0]).to_f*1000
      point << row[1].to_f
      data << point
    end
    LazyHighCharts::HighChart.new('area') do |f|
      f.title({:text => sprintf( "%s - %s", chart.table, chart.name )})
      f.options[:xAxis][:type] = "datetime"
      f.options[:xAxis][:ordinal] = false
      f.options[:chart][:zoomType] = "xy"
      f.options[:plotOptions][:area] = {
        :fillColor => {
                        :linearGradient => { :x1 => 0, :y1=> 0, :x2=> 0, :y2=> 1},
                        :stops => [
                            [0, "#4169E1"],
                            [1, "#FFFFFF"]
                        ]
                    },
        :lineWidth => 1, 
        :marker => {:enabled => false},
        :shadow => false
      } 
      f.series(:type => 'area', :name=> 'ROE',:data=> data)
    end
  end

end
