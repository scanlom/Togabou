require 'accounts.rb'
require 'assets.rb'

class PagesController < ApplicationController
  include ActionView::Helpers::NumberHelper
  
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
  
  def get_actions( type, start_date, end_date )
    where = sprintf( "actions_type_id = %d and date >= '%s'", type, start_date )
    if( end_date != nil )
      where = sprintf( "%s and date < '%s'", where, end_date )
    end
    Action.where( where )
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
      f.options[:chart][:zoomType] = "x"
      f.options[:plotOptions][:line] = {
        :lineWidth => 1, 
        :marker => {:enabled => false},
        :shadow => false
      } 
      f.series(:type => 'line', :name=> chart.name, :data=> data)
    end
  end

  def get_chart_expenses
    conn = ActiveRecord::Base.connection
    h = Hash.new
    res = conn.execute( "select t.description, extract(month from s.date) as month, sum(s.amount) as amount from spending s, spending_types t where s.type = t.type and s.date > '12/31/2013' group by t.description, month order by t.description, month asc" )
    res.values().each do |row|
      a = Array.new
      if h.has_key?( row[0] )
        a = h[ row[0] ]
      else
        h[ row[0] ] = a
      end
      a << row[2].to_f
    end
    
    # Create the title
    a = get_accounts( nil ) 
    paid = a.get_balance_value( Togabou::BALANCES_PAID )
    tax = a.get_balance_value( Togabou::BALANCES_TAX )
    savings = a.get_balance_value( Togabou::BALANCES_SAVINGS )
    spent = paid - tax - savings 
    res = conn.execute( "select sum(amount) as value from spending where date > '12/31/2013'" )
    expenses = res.first['value'].to_f
    
    day = a.date.yday.to_f
    if day == 1
      day = 365
    end
    spent_projected = 365 / day * spent
    expenses_projected = 365 / day * expenses
    budget_projected = 97651.56
    budget = day / 365 * budget_projected
      
    title = sprintf( "Expenses - %s / %s Spent - %s / %s Budget - %s / %s",
      number_with_precision( expenses, :precision => 2, :delimiter => ","),
      number_with_precision( expenses_projected, :precision => 2, :delimiter => ","),
      number_with_precision( spent, :precision => 2, :delimiter => ","), 
      number_with_precision( spent_projected, :precision => 2, :delimiter => ","), 
      number_with_precision( budget, :precision => 2, :delimiter => ","), 
      number_with_precision( budget_projected, :precision => 2, :delimiter => ",") ) 
              
    LazyHighCharts::HighChart.new('column') do |f|
      f.title({:text => title})
      f.options[:xAxis][:categories] = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]
      f.options[:plotOptions][:column] = { :stacking => 'normal' }
      h.keys().each do |key|
        f.series(:type => 'column', :name=> key.to_s, :data=> h[ key ])
      end
    end
  end
  
end
