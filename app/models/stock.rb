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
    @value = get_scalar( conn, sprintf( "select value from portfolio where symbol='%s'", self.symbol ) )
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
end
