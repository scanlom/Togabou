class Constituent < ApplicationRecord
  belongs_to :portfolio
  belongs_to :stock
  attr_accessor :actual
  attr_accessor :off
  attr_accessor :eps_yield_wtd
  attr_accessor :div_yield_wtd

  after_initialize :initialize_members
  def initialize_members
    conn = ActiveRecord::Base.connection
    @actual = self.value.to_f / get_scalar( conn, "select value from balances where type=13" ).to_f
    if self.portfolio != nil && self.portfolio.id == Togabou::PORTFOLIOS_PLAY
      @actual = self.value.to_f / get_scalar( conn, "select value from balances where type=19" ).to_f
    end

    @off = self.actual.to_f - self.model.to_f
    if self.stock != nil
      @eps_yield_wtd = self.actual.to_f * self.stock.eps_yield.to_f
      @div_yield_wtd = self.actual.to_f * self.stock.div_yield.to_f
    else
      @eps_yield_wtd = 0
      @div_yield_wtd = 0
    end
  end
end
