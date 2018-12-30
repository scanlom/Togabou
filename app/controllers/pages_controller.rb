require 'accounts.rb'
require 'assets.rb'

class PagesController < ApplicationController
  include ActionView::Helpers::NumberHelper

  attr_accessor :chart_infos

  def initialize

    # Get the chart types
    @chart_infos = Array.new
    chart_info = Struct.new( :table, :where, :name, :multi )
    conn = ActiveRecord::Base.connection

    # index_history chart types
    res = conn.execute( "select type, description from divisors_types order by type asc" )
    res.values().each do |row|
      @chart_infos << chart_info.new( "index_history", sprintf( "type = %d", row[0] ), row[1], false )
    end

    # portfolio_history chart types
    res = conn.execute( "select distinct symbol, type from portfolio_history order by symbol asc" )
    res.values().each do |row|
      @chart_infos << chart_info.new( "portfolio_history", sprintf( "symbol = '%s' and type = %d", row[0], row[1] ), sprintf( "%s - %s", row[0], row[1] ), false )
    end

    # portfolio_history_multi chart types
    res = conn.execute( "select distinct type from portfolio_history order by type asc" )
    res.values().each do |row|
      @chart_infos << chart_info.new( "portfolio_history", sprintf( "type = %d", row[0] ), sprintf( "multi - %s", row[0] ), true )
    end

    # balances_history chart types
    res = conn.execute( "select type, description from balances order by type asc" )
    res.values().each do |row|
      @chart_infos << chart_info.new( "balances_history", sprintf( "type = %d", row[0] ), row[1], false )
    end

    super
  end

  def get_actions( type, start_date, end_date )
    where = sprintf( "actions_type_id = %d and date >= '%s'", type, start_date )
    if( end_date != nil )
      where = sprintf( "%s and date <= '%s'", where, end_date )
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

  def get_default_chart_number
    "1" # The ROE chart
  end

  def get_chart( chart_number )
    chart_number = chart_number.to_i
    conn = ActiveRecord::Base.connection
    chart = @chart_infos[ chart_number ]
    if chart.multi
      series = Hash.new
      res = conn.execute( sprintf( "select distinct symbol from %s where %s", chart.table, chart.where ) )
      res.values().each do |row|
        data = Array.new
        series[row[0]] = data
        res_data = conn.execute( sprintf( "select date, value from %s where symbol='%s' and %s order by date asc", chart.table, row[0], chart.where ) )
        res_data.values().each do |row_data|
          point = Array.new
          point << DateTime.parse(row_data[0]).to_f*1000
          point << row_data[1].to_f
          data << point
        end
      end
      LazyHighCharts::HighChart.new('area') do |f|
        f.title({:text => sprintf( "%s - %s", chart.table, chart.name )})
        f.options[:xAxis][:type] = "datetime"
        f.options[:xAxis][:ordinal] = false
        f.options[:chart][:zoomType] = "x"
        f.options[:tooltip][:formatter] = "function() {
           var d = new Date( this.x ); var s = '<strong>' + d.toDateString() + '</strong>';
           var sortedPoints = this.points.sort(function(a, b){
             return ((a.y < b.y) ? 1 : ((a.y > b.y) ? -1 : 0));
             });
           var total = this.points.reduce(function(a, b){ return a + b.y; }, 0);
           
           // The maximum rows we can show in the tooltip is about 11, over that we will overflow the visible space in the chart, after which the tooltip 
           // doesn't show up at all.  That seems like a bug in either high charts or the lazy gem, but in any event it doesn't make sense to show a ginormous
           // tooltip.  So here we will decide how many components to show values for, and put the rest on the final line with only %'s 
           var showAsSingle = 11
           if (sortedPoints.length > showAsSingle) {
            showAsSingle -= 1
           }
           $.each(sortedPoints, function(i, point) {
             if (i < showAsSingle) {
              s += '<br/><p style=\"font-weight:bold; color:' + point.series.color + '\">' + point.series.name + ': <span style=\"color:#000000\">' +
                point.y.toLocaleString( \"en-US\", { minimumFractionDigits:2 } ) + '</span> ' + ( 100 * point.y / total ).toLocaleString( \"en-US\", { minimumFractionDigits:2, maximumFractionDigits:2 } ) + '%</p>';
            } else {
              if (i == showAsSingle) { s += '<br/>' }
              else { s += ', ' }  
              s += point.series.name + ' ' + ( 100 * point.y / total ).toLocaleString( \"en-US\", { minimumFractionDigits:2, maximumFractionDigits:2 } ) + '%'
            }  
           });
           return s; }".js_code
        f.options[:legend] = { :layout => 'horizontal' }
        f.options[:plotOptions][:line] = {
          :lineWidth => 1,
          :marker => {:enabled => false},
          :shadow => false
        }
        series.each { | key,value | f.series(:type => 'line', :name=> key, :data=> value) }
      end
    else
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
        f.options[:tooltip][:formatter] = "function() {
            var d = new Date( this.x ); var s = '<strong>' + d.toDateString() + '</strong>';
            var point = this.points[0]
            s += '<br/><p style=\"font-weight:bold; color:' + point.series.color + '\">' + point.series.name + ': <span style=\"color:#000000\">' +
                 point.y.toLocaleString( \"en-US\", { minimumFractionDigits:2 } ) + '</span></p>';
            return s; }".js_code
        f.options[:legend] = { :layout => 'horizontal' }
        f.options[:plotOptions][:line] = {
          :lineWidth => 1,
          :marker => {:enabled => false},
          :shadow => false
        }
        f.series(:type => 'line', :name=> chart.name, :data=> data)
      end
    end
  end

  def get_chart_expenses
    conn = ActiveRecord::Base.connection
    h = Hash.new
    res = conn.execute( "select t.description, extract(month from s.date) as month, sum(s.amount) as amount from spending s, spending_types t where s.type = t.type and s.date >= to_date( '01/01/' || date_part('year', current_date), 'mm/dd/YYYY') group by t.description, month order by t.description, month asc" )
    res.values().each do |row|
      a = Array.new( 12 )
      if h.has_key?( row[0] )
        a = h[ row[0] ]
      else
        h[ row[0] ] = a
      end
      a[ row[1].to_i - 1 ] = row[2].to_f
    end

    # Create the title
    a = get_accounts( nil )
    paid = a.get_balance_value( Togabou::BALANCES_PAID )
    tax = a.get_balance_value( Togabou::BALANCES_TAX )
    savings = a.get_balance_value( Togabou::BALANCES_SAVINGS )
    spent = paid - tax - savings
    res = conn.execute( "select sum(amount) as value from spending where date >= to_date( '01/01/' || date_part('year', current_date), 'mm/dd/YYYY')" )
    expenses = res.first['value'].to_f

    day = a.date.yday.to_f
    if day == 1
      day = 365
    end
    spent_projected = 365 / day * spent
    expenses_projected = 365 / day * expenses
    budget_projected = 151000
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
      f.options[:legend] = { :layout => 'horizontal' }
      h.keys().each do |key|
        f.series(:type => 'column', :name=> key.to_s, :data=> h[ key ])
      end
    end
  end

end
