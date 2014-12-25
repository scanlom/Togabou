require 'open-uri'

def get_scalar( conn, sql )
  res = conn.execute( sql )
  if res == nil or res.first == nil
    0
  else
    res.first['value']
  end
end

class Stock < ActiveRecord::Base
  has_many :researches, :order => "date DESC"
  has_many :fundamentals, :order => "date DESC"

  DIV_GROWTH = 0.0686

  attr_accessor :value
  attr_accessor :portfolio
  attr_accessor :off
  attr_accessor :pe
  attr_accessor :eps_yield
  attr_accessor :div_yield
  attr_accessor :eps_yield_wtd
  attr_accessor :div_yield_wtd
  attr_accessor :div_plus_growth
  attr_accessor :five_year_cagr
  attr_accessor :ten_year_cagr
  attr_accessor :five_year_croe
  attr_accessor :ten_year_croe

  after_initialize :initialize_members
  def initialize_members

    # Populate value and percentage from db
    conn = ActiveRecord::Base.connection
    @value = get_scalar( conn, sprintf( "select value from constituents where symbol='%s'", self.symbol ) )
    @portfolio = @value.to_f / get_scalar( conn, "select value from balances where type=13" ).to_f

    # Populate calculated values
    @off = self.portfolio.to_f - self.model.to_f
    @pe = self.price / self.eps
    @eps_yield = self.eps.to_f / self.price.to_f
    @div_yield = self.div.to_f / self.price.to_f
    @eps_yield_wtd = self.portfolio.to_f * self.eps_yield.to_f
    @div_yield_wtd = self.portfolio.to_f * self.div_yield.to_f
    @div_plus_growth = self.div_yield + self.growth
    @five_year_cagr = cagr( 5 )
    @ten_year_cagr = cagr( 10 )
    @five_year_croe = croe( 5 )
    @ten_year_croe = croe( 10 )
  end

  def price
    if self[:price] == nil or self[:price] <= 0
      # Populate price from yahoo
      url = sprintf("http://finance.yahoo.com/d/quotes.csv?s=%s&f=%s", self.symbol, "l1")
      self[:price] = open(url).readline
    end
    self[:price]
  end

  def cagr( years )
    div_bucket = 0
    eps = self.eps.to_f
    (1..years).each do |i|
      div_bucket = div_bucket.to_f * (1.to_f + DIV_GROWTH.to_f)
      div_bucket = div_bucket.to_f + (eps.to_f * self.payout.to_f)
      eps = eps.to_f * (1 + self.growth.to_f)
    end
    ((((eps.to_f * self.pe_terminal.to_f) + div_bucket.to_f) / self.price.to_f) ** (1.to_f/years.to_f)) - 1.to_f
  end

  def croe( years )
    div_bucket = 0
    eps = 0
    book = self.book.to_f
    div = 0
    (1..years).each do |i|
      div_bucket = div_bucket.to_f * (1.to_f + DIV_GROWTH.to_f)
      eps = book * self.roe.to_f
      div = eps * self.payout.to_f
      div_bucket = div_bucket.to_f + div.to_f
      book = book.to_f + eps.to_f - div.to_f
    end
    ((((eps.to_f * self.pe_terminal.to_f) + div_bucket.to_f) / self.price.to_f) ** (1.to_f/years.to_f)) - 1.to_f
  end

  def reminder
    ret = 0
    if self.researches.length <= 0
      ret = 2
    elsif self.researches[ 0 ].date > 1.month.ago
      ret = 0
    elsif self.researches[ 0 ].date > 3.months.ago
      ret = 1
    else
      ret = 2
    end
    ret
  end

  def two_year_eps
    ret = 0
    if self.researches.length <= 0 or self.fundamentals.length <= 0 or self.researches[0].eps_yr2.nil? or self.fundamentals[0].eps.nil? or self.fundamentals[0].eps <= 0
      ret = 0
    else
      ret = ( self.researches[0].eps_yr2 / self.fundamentals[0].eps ) ** 0.5 - 1
    end
    ret
  end

  def seven_year_eps
    ret = 0
    if self.researches.length <= 0 or self.fundamentals.length <= 5 or self.researches[0].eps_yr2.nil? or self.fundamentals[5].eps.nil? or self.fundamentals[5].eps <= 0
      ret = 0
    else
      ret = ( self.researches[0].eps_yr2 / self.fundamentals[ 5 ].eps ) ** ( 1 / 7.0 ) - 1
    end
    ret
  end

  def x_year_eps( year )
    ret = 0
    if self.fundamentals.length <= year
      ret = 0
    else
      ret = ( self.fundamentals[0].eps / self.fundamentals[ year ].eps ) ** ( 1 / year.to_f ) - 1
    end
    ret
  end

  def average_roe( year )
    ret = 0
    if self.fundamentals.length < year
      ret = 0
    else
      ret = self.fundamentals[0, year].inject(0.0){ |sum,e| sum += e.roe } / year.to_f
    end
    ret
  end

  def average_pe_high( year )
    ret = 0
    if self.fundamentals.length < year
      ret = 0
    else
      sorted = self.fundamentals[0, year].sort {|a,b| a.pe_high <=> b.pe_high }
      ret = year % 2 == 1 ? sorted[year/2].pe_high : (sorted[year/2 - 1].pe_high + sorted[year/2]).pe_high.to_f / 2
    end
    ret
  end

  def average_pe_low( year )
    ret = 0
    if self.fundamentals.length < year
      ret = 0
    else
      sorted = self.fundamentals[0, year].sort {|a,b| a.pe_low <=> b.pe_low }
      ret = year % 2 == 1 ? sorted[year/2].pe_low : (sorted[year/2 - 1].pe_low + sorted[year/2]).pe_low.to_f / 2
    end
    ret
  end
end
