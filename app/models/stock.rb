require 'open-uri'

def get_scalar( conn, sql )
  res = conn.execute( sql )
  if res == nil or res.first == nil
    0
  else
    res.first['value']
  end
end

class Stock < ApplicationRecord
  has_many :researches, -> { order "date DESC" }
  has_many :fundamentals, -> { order "date DESC" }
  has_many :constituents, -> { order "portfolio_id ASC" }
  accepts_nested_attributes_for :constituents, update_only: true

  attr_accessor :pe
  attr_accessor :eps_yield
  attr_accessor :div_yield
  attr_accessor :div_plus_growth
  attr_accessor :five_year_cagr
  attr_accessor :ten_year_cagr
  attr_accessor :five_year_croe
  attr_accessor :ten_year_croe
  attr_accessor :confidence
  attr_accessor :confidence_num

  after_initialize :initialize_members
  def initialize_members
    if ( ( self.price == nil || self.price <= 0 ) && self.symbol != nil )
      # Populate price from AlphaVantage
      logger.info sprintf( "Retrieving last from AlphaVantage for %s...", self.symbol )
      url = sprintf("https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=%s&apikey=2YG6SAN57NRYNPJ8", self.symbol)
      data = JSON.load(open(url))
      self.price = data['Global Quote']['05. price'].to_f
      logger.info sprintf( "Retrieved %f from AlphaVantage for %s", self.price, self.symbol )
    end

    # Populate calculated values
    if self.price != nil && self.price > 0
      @pe = self.price / self.eps
      @eps_yield = self.eps / self.price
      @div_yield = self.div / self.price
      @div_plus_growth = self.div_yield + self.growth
      @five_year_cagr = cagr( 5 )
      @ten_year_cagr = cagr( 10 )
      @five_year_croe = croe( 5 )
      @ten_year_croe = croe( 10 )
    end
    
    @confidence = Togabou::CONFIDENCE_NONE
    if self.researches.length > 0
      @confidence = self.researches[0].confidence
    end

    if self.confidence == Togabou::CONFIDENCE_HIGH
        @confidence_num = 0
    elsif self.confidence == Togabou::CONFIDENCE_MEDIUM
        @confidence_num = 1
    elsif self.confidence == Togabou::CONFIDENCE_NONE
        @confidence_num = 2
    elsif self.confidence == Togabou::CONFIDENCE_LOW
        @confidence_num = 3
    end
  end

  def cagr( years )
    div_bucket = 0.0
    eps = self.eps
    (1..years).each do |i|
      div_bucket = div_bucket * (1 + Togabou::DIV_GROWTH)
      div_bucket = div_bucket + (eps * self.payout)
      eps = eps * (1 + self.growth)
    end
    ((((eps * self.pe_terminal) + div_bucket) / self.price) ** (1.0 / years)) - 1
  end

  def croe( years )
    div_bucket = 0.0
    eps = 0
    book = self.book
    div = 0
    (1..years).each do |i|
      div_bucket = div_bucket * (1 + Togabou::DIV_GROWTH)
      eps = book * self.roe
      div = eps * self.payout
      div_bucket = div_bucket + div
      book = book + eps - div
    end
    ((((eps * self.pe_terminal) + div_bucket) / self.price) ** (1.0 / years)) - 1
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
    if self.fundamentals.length <= year || self.fundamentals[ year ].eps <= 0
      ret = 0
    else
      ret = ( self.fundamentals[0].eps / self.fundamentals[ year ].eps ) ** ( 1.0 / year ) - 1
    end
    ret
  end

  def average_roe( year )
    ret = 0
    if self.fundamentals.length < year
      ret = 0
    else
      ret = self.fundamentals[0, year].inject(0.0){ |sum,e| sum += e.roe } / year
    end
    ret
  end

  def average_pe_high( year )
    ret = 0
    if self.fundamentals.length < year
      ret = 0
    else
      sorted = self.fundamentals[0, year].sort {|a,b| a.pe_high <=> b.pe_high }
      ret = year % 2 == 1 ? sorted[year/2.0].pe_high : (sorted[year/2.0 - 1].pe_high + sorted[year/2.0]).pe_high / 2.0
    end
    ret
  end

  def average_pe_low( year )
    ret = 0
    if self.fundamentals.length < year
      ret = 0
    else
      sorted = self.fundamentals[0, year].sort {|a,b| a.pe_low <=> b.pe_low }
      ret = year % 2 == 1 ? sorted[year/2.0].pe_low : (sorted[year/2.0 - 1].pe_low + sorted[year/2.0]).pe_low / 2.0
    end
    ret
  end
end
