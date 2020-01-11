
def get_scalar( conn, sql )
  res = conn.execute( sql )
  if res == nil or res.first == nil
    0.to_f
  else
    res.first['value'].to_f
  end
end

class Position
  attr_accessor :symbol
  attr_accessor :value
  attr_accessor :quantity
  attr_accessor :price
  def initialize(symbol, value, quantity = nil, price = nil)
    @symbol = symbol
    @value = value
    @quantity = quantity
    @price = price
  end
end

class Allocation
  attr_accessor :symbol
  attr_accessor :primary
  attr_accessor :secondary
  attr_accessor :primary_ordinal
  attr_accessor :secondary_ordinal
  attr_accessor :primary_sum
  attr_accessor :secondary_sum
  attr_accessor :percentage
  def initialize( conn, symbol, value, total )
    if conn != nil
      @symbol = symbol

      # Determine the allocation information for this symbol
      res = conn.execute( sprintf( "select first, secondary, primary_ordinal, secondary_ordinal from allocations where symbol='%s'", symbol ) )
      @primary = res.first['first']
      @secondary = res.first['secondary']
      @primary_ordinal = res.first['primary_ordinal']
      @secondary_ordinal = res.first['secondary_ordinal']
    else
      @primary = symbol
    end

    # Calcualte percentage
    @percentage = 100 * ( value.to_f / total.to_f )

  end
end

# Named Portfolio2 as I screwed up and there is a model of the same name
class Portfolio2
  attr_accessor :positions
  attr_accessor :cash
  attr_accessor :total
  attr_accessor :divisor
  attr_accessor :index

  def initialize( conn, date, type, balance_type, index_type )

    # Download positions
    @positions = Array.new
    res = conn.execute( sprintf( "select symbol, value, quantity, price from portfolio_history where date='%s' and type=%s and symbol<>'CASH' order by value desc", date.to_s(:db), type.to_s ) )
    res.values().each do |row|
      @positions << Position.new( row[0], row[1], row[2], row[3] )
    end

    # Download scalars
    if balance_type > 0
      @cash = get_scalar( conn, sprintf( "select value from portfolio_history where date='%s' and type=%s and symbol='CASH'", date.to_s(:db), type.to_s ) )
      @total = get_scalar( conn, sprintf( "select value from balances_history where date='%s' and type=%s", date.to_s(:db), balance_type.to_s ) )
      @divisor = get_scalar( conn, sprintf( "select value from divisors_history where date='%s' and type=%s", date.to_s(:db), index_type.to_s ) )
      @index = get_scalar( conn, sprintf( "select value from index_history where date='%s' and type=%s", date.to_s(:db), index_type.to_s ) )
    end
  end
end

class Assets
  attr_accessor :date
  attr_accessor :portfolio
  attr_accessor :managed
  attr_accessor :other
  attr_accessor :play
  attr_accessor :cash
  attr_accessor :debt
  attr_accessor :roe_total
  attr_accessor :roe_base
  attr_accessor :roe_divisor
  attr_accessor :roe_index
  attr_accessor :rotc_total
  attr_accessor :rotc_divisor
  attr_accessor :rotc_index
  attr_accessor :ret_ytd_roe
  attr_accessor :ret_ytd_rotc
  attr_accessor :ret_ytd_portfolio
  attr_accessor :ret_ytd_managed
  attr_accessor :ret_ytd_play
  attr_accessor :ret_qtd_roe
  attr_accessor :ret_qtd_rotc
  attr_accessor :ret_qtd_portfolio
  attr_accessor :ret_qtd_managed
  attr_accessor :ret_qtd_play
  attr_accessor :ret_day_roe
  attr_accessor :ret_day_rotc
  attr_accessor :ret_day_portfolio
  attr_accessor :ret_day_managed
  attr_accessor :ret_day_play
  attr_accessor :profit
  attr_accessor :ret_week_roe
  attr_accessor :ret_week_rotc
  attr_accessor :ret_week_portfolio
  attr_accessor :ret_week_managed
  attr_accessor :ret_week_play
  attr_accessor :ret_month_roe
  attr_accessor :ret_month_rotc
  attr_accessor :ret_month_portfolio
  attr_accessor :ret_month_managed
  attr_accessor :ret_month_play
  attr_accessor :ret_three_month_roe
  attr_accessor :ret_three_month_rotc
  attr_accessor :ret_three_month_portfolio
  attr_accessor :ret_three_month_managed
  attr_accessor :ret_three_month_play
  attr_accessor :ret_year_roe
  attr_accessor :ret_year_rotc
  attr_accessor :ret_year_portfolio
  attr_accessor :ret_year_managed
  attr_accessor :ret_year_play
  attr_accessor :ret_five_year_roe
  attr_accessor :ret_five_year_rotc
  attr_accessor :ret_five_year_portfolio
  attr_accessor :ret_five_year_managed
  attr_accessor :ret_five_year_play
  attr_accessor :ret_ten_year_roe
  attr_accessor :ret_ten_year_rotc
  attr_accessor :ret_ten_year_portfolio
  attr_accessor :ret_ten_year_managed
  attr_accessor :ret_ten_year_play

  def initialize(date = nil)
    conn = ActiveRecord::Base.connection

    # If no date is passed in, use max date
    date_sql = "select max(p.date) date from portfolio_history p"
    if date != nil and date != ""
      date_sql += " where p.date <= '" + date.to_s(:db) + "'"
    end
    res = conn.execute( date_sql )
    @date = Date.parse( res.first['date'] )

    # Load the portfolios
    @portfolio = Portfolio2.new( conn, @date, 1, 13, 1 )
    @managed = Portfolio2.new( conn, @date, 2, 14, 4 )
    @other = Portfolio2.new( conn, @date, 4, -1, -1 )
    @play = Portfolio2.new( conn, @date, 5, 19, 5 )

    # Load the scalars
    @cash = get_scalar( conn, sprintf( "select value from portfolio_history where date='%s' and type=3 and symbol='CASH'", @date.to_s(:db) ) )
    @debt = get_scalar( conn, sprintf( "select value from portfolio_history where date='%s' and type=3 and symbol='DEBT'", @date.to_s(:db) ) )
    @roe_total = get_scalar( conn, sprintf( "select value from balances_history where date='%s' and type=12", @date.to_s(:db ) ) )
    @roe_divisor = get_scalar( conn, sprintf( "select value from divisors_history where date='%s' and type=2", @date.to_s(:db) ) )
    @roe_index = get_scalar( conn, sprintf( "select value from index_history where date='%s' and type=2", @date.to_s(:db) ) )
    @rotc_total = get_scalar( conn, sprintf( "select value from balances_history where date='%s' and type=18", @date.to_s(:db ) ) )
    @rotc_divisor = get_scalar( conn, sprintf( "select value from divisors_history where date='%s' and type=3", @date.to_s(:db) ) )
    @rotc_index = get_scalar( conn, sprintf( "select value from index_history where date='%s' and type=3", @date.to_s(:db) ) )

    # Calculate returns
    @ret_ytd_roe = calculate_return( self.roe_index, get_ytd_base( conn, 2 ) )
    @ret_ytd_rotc = calculate_return( self.rotc_index, get_ytd_base( conn, 3 ) )
    @ret_ytd_portfolio = calculate_return( self.portfolio.index, get_ytd_base( conn, 1 ) )
    @ret_ytd_managed = calculate_return( self.managed.index, get_ytd_base( conn, 4 ) )
    @ret_ytd_play = calculate_return( self.play.index, get_ytd_base( conn, 5 ) )
    @ret_qtd_roe = calculate_return( self.roe_index, get_qtd_base( conn, 2 ) )
    @ret_qtd_rotc = calculate_return( self.rotc_index, get_qtd_base( conn, 3 ) )
    @ret_qtd_portfolio = calculate_return( self.portfolio.index, get_qtd_base( conn, 1 ) )
    @ret_qtd_managed = calculate_return( self.managed.index, get_qtd_base( conn, 4 ) )
    @ret_qtd_play = calculate_return( self.play.index, get_qtd_base( conn, 5 ) )
    @ret_day_roe = calculate_return( self.roe_index, get_day_base( conn, 2 ) )
    @ret_day_rotc = calculate_return( self.rotc_index, get_day_base( conn, 3 ) )
    @ret_day_portfolio = calculate_return( self.portfolio.index, get_day_base( conn, 1 ) )
    @ret_day_managed = calculate_return( self.managed.index, get_day_base( conn, 4 ) )
    @ret_day_play = calculate_return( self.play.index, get_day_base( conn, 5 ) )
    savings = get_scalar( conn, sprintf( "select value from balances_history where date='%s' and type=17", @date.to_s(:db) ) )
    @roe_base = get_ytd_balance_base( conn, Togabou::BALANCES_TOTAL_ROE ).to_f
    if @roe_base <= 0
      @profit = 0
    else
      @profit = self.roe_total.to_f - @roe_base - savings.to_f
    end

    # More returns
    @ret_week_roe = calculate_return( self.roe_index, get_base( conn, 2, @date - 1.week ) )
    @ret_week_rotc = calculate_return( self.rotc_index, get_base( conn, 3, @date - 1.week ) )
    @ret_week_portfolio = calculate_return( self.portfolio.index, get_base( conn, 1, @date - 1.week ) )
    @ret_week_managed = calculate_return( self.managed.index, get_base( conn, 4, @date - 1.week ) )
    @ret_week_play = calculate_return( self.play.index, get_base( conn, 5, @date - 1.week ) )
    @ret_month_roe = calculate_return( self.roe_index, get_base( conn, 2, @date - 1.month ) )
    @ret_month_rotc = calculate_return( self.rotc_index, get_base( conn, 3, @date - 1.month ) )
    @ret_month_portfolio = calculate_return( self.portfolio.index, get_base( conn, 1, @date - 1.month ) )
    @ret_month_managed = calculate_return( self.managed.index, get_base( conn, 4, @date - 1.month ) )
    @ret_month_play = calculate_return( self.play.index, get_base( conn, 5, @date - 1.month ) )
    @ret_three_month_roe = calculate_return( self.roe_index, get_base( conn, 2, @date - 3.months ) )
    @ret_three_month_rotc = calculate_return( self.rotc_index, get_base( conn, 3, @date - 3.months ) )
    @ret_three_month_portfolio = calculate_return( self.portfolio.index, get_base( conn, 1, @date - 3.months ) )
    @ret_three_month_managed = calculate_return( self.managed.index, get_base( conn, 4, @date - 3.months ) )
    @ret_three_month_play = calculate_return( self.play.index, get_base( conn, 5, @date - 3.months ) )
    @ret_year_roe = calculate_return( self.roe_index, get_base( conn, 2, @date - 1.year ) )
    @ret_year_rotc = calculate_return( self.rotc_index, get_base( conn, 3, @date - 1.year ) )
    @ret_year_portfolio = calculate_return( self.portfolio.index, get_base( conn, 1, @date - 1.year ) )
    @ret_year_managed = calculate_return( self.managed.index, get_base( conn, 4, @date - 1.year ) )
    @ret_year_play = calculate_return( self.play.index, get_base( conn, 5, @date - 1.year ) )
    @ret_five_year_roe = calculate_return( self.roe_index, get_base( conn, 2, @date - 5.years ), 5 )
    @ret_five_year_rotc = calculate_return( self.rotc_index, get_base( conn, 3, @date - 5.years ), 5 )
    @ret_five_year_portfolio = calculate_return( self.portfolio.index, get_base( conn, 1, @date - 5.years ), 5 )
    @ret_five_year_managed = calculate_return( self.managed.index, get_base( conn, 4, @date - 5.years ), 5 )
    @ret_five_year_play = calculate_return( self.play.index, get_base( conn, 5, @date - 5.years ), 5 )
    @ret_ten_year_roe = calculate_return( self.roe_index, get_base( conn, 2, @date - 10.years ), 10 )
    @ret_ten_year_rotc = calculate_return( self.rotc_index, get_base( conn, 3, @date - 10.years ), 10 )
    @ret_ten_year_portfolio = calculate_return( self.portfolio.index, get_base( conn, 1, @date - 10.years ), 10 )
    @ret_ten_year_managed = calculate_return( self.managed.index, get_base( conn, 4, @date - 10.years ), 10 )
    @ret_ten_year_play = calculate_return( self.play.index, get_base( conn, 5, @date - 10.years ), 10 )
  end

  def normalize_allocations( allocations )

    # Sort by percentage, then secondary, then primary
    allocations.sort! { |a,b| [ a.primary_ordinal, a.secondary_ordinal, b.percentage ] <=> [ b.primary_ordinal, b.secondary_ordinal, a.percentage ] }

    # Now sum up the primary and secondary levels
    primary = Hash.new(0)
    secondary = Hash.new(0)
    allocations.each do |allocation|
      primary[allocation.primary] += allocation.percentage
      secondary[allocation.primary + ":" + allocation.secondary] += allocation.percentage
    end

    # Add these sums to the allocations so the html table can reference them
    allocations.each do |allocation|
      if secondary.key?( allocation.primary + ":" + allocation.secondary )
        allocation.secondary_sum = secondary[allocation.primary + ":" + allocation.secondary]
        secondary.delete( allocation.primary + ":" + allocation.secondary )
      else
        allocation.secondary = nil
        allocation.secondary_sum = nil
      end
      if primary.key?( allocation.primary )
        allocation.primary_sum = primary[allocation.primary]
        primary.delete( allocation.primary )
      else
        allocation.primary = nil
        allocation.primary_sum = nil
      end
    end

    allocations
  end

  def get_asset_allocations
    conn = ActiveRecord::Base.connection
    allocations = Array.new
    @portfolio.positions.each do |position|
      allocation = Allocation.new( conn, position.symbol, position.value, @roe_total )
      allocation.secondary = "Self" # Override for self positions, as we may hold the same asset in managed (JPM)
      allocation.secondary_ordinal = 1
      allocations << allocation
    end
    allocation = Allocation.new( nil, "CASH",  @portfolio.cash.to_f, roe_total )
    allocation.symbol= "CASH"
    allocation.primary = "DomEq"
    allocation.primary_ordinal = 1
    allocation.secondary = "Self"
    allocation.secondary_ordinal = 1
    allocations << allocation
    @managed.positions.each do |position|
      allocations << Allocation.new( conn, position.symbol, position.value, @roe_total )
    end
    allocation = Allocation.new( nil, "CASH",  @managed.cash.to_f, roe_total )
    allocation.symbol= "CASH"
    allocation.primary = "Cash"
    allocation.primary_ordinal = 9
    allocation.secondary = "Cash"
    allocation.secondary_ordinal = 1
    allocations << allocation
    @other.positions.each do |position|
      allocations << Allocation.new( conn, position.symbol, position.value, @roe_total )
    end

    allocations = normalize_allocations( allocations )

    # Add Cash, Check, Debt (bit of a hack, but hopefully you can follow)
    debt_percentage = 100 * ( @debt.to_f / @roe_total.to_f )
    allocations << Allocation.new( nil, "CASH",  @cash.to_f, roe_total )
    allocations << Allocation.new( nil, "CHECK", allocations.inject(0){ |sum,x| sum += x.percentage } - debt_percentage, 100 )
    allocations << Allocation.new( nil, "DEBT", @debt, @roe_total )

    allocations
  end

  def get_asset_allocations_managed
    conn = ActiveRecord::Base.connection
    allocations = Array.new
    @managed.positions.each do |position|
      allocations << Allocation.new( conn, position.symbol, position.value, @managed.total )
    end
    allocation = Allocation.new( nil, "CASH",  @managed.cash.to_f, @managed.total )
    allocation.symbol= "CASH"
    allocation.primary = "Cash"
    allocation.primary_ordinal = 9
    allocation.secondary = "Cash"
    allocation.secondary_ordinal = 1
    allocations << allocation

    allocations = normalize_allocations( allocations )

    # Add Cash, Check, Debt (bit of a hack, but hopefully you can follow)
    allocations << Allocation.new( nil, "CHECK", allocations.inject(0){ |sum,x| sum += x.percentage }, 100 )

    allocations
  end

  def calculate_return( current, base, years = 1 )
    ret = 0
    if base.to_f > 0
      ret = ( current.to_f / base.to_f ) ** ( 1 / years.to_f ) - 1
    end
    ret
  end

  def get_base( conn, index, date )
    get_scalar( conn, sprintf( "select * from index_history where type=%s and
      date = ( select max(date) from index_history where date <= '%s' )", index, date.to_s(:db) ) )
  end

  def get_ytd_base( conn, index )
    date = "01/01/" + self.date.year.to_s
    if self.date.month == 1 && self.date.day == 1
        date = "01/01/" + (self.date.year - 1).to_s
    end
    get_scalar( conn, sprintf( "select * from index_history where type=%s and date='%s'", index, date ) )
  end

  def get_qtd_base( conn, index )
    date = "10/01/" + (self.date.year - 1).to_s
    if self.date.month > 9 && !(self.date.month == 10 && self.date.day == 1)
        date = "10/01/" + self.date.year.to_s
    elsif self.date.month > 6 && !(self.date.month == 7 && self.date.day == 1)
        date = "07/01/" + self.date.year.to_s
    elsif self.date.month > 3 && !(self.date.month == 4 && self.date.day == 1)
        date = "04/01/" + self.date.year.to_s
    elsif !(self.date.month == 1 && self.date.day == 1)
        date = "01/01/" + self.date.year.to_s
    end
    get_scalar( conn, sprintf( "select * from index_history where type=%s and date='%s'", index, date ) )
  end

  def get_day_base( conn, index )
    date = self.date - 1.day
    get_scalar( conn, sprintf( "select * from index_history where type=%s and date='%s'", index, date ) )
  end

  def get_ytd_balance_base( conn, type )
    date = "01/01/" + self.date.year.to_s
    if self.date.month == 1 && self.date.day == 1
        date = "01/01/" + (self.date.year - 1).to_s
    end
    get_scalar( conn, sprintf( "select * from balances_history where type=%d and date='%s'", type, date ) )
  end

  def portfolio_internal( portfolio_id )
    ret = self.portfolio
    if portfolio_id == Togabou::PORTFOLIOS_PLAY
      ret = self.play
    end
    ret
  end
end

