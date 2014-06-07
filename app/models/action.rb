class Action < ActiveRecord::Base
  belongs_to :actions_type

  after_initialize :initialize_members
  def initialize_members
    @conn = ActiveRecord::Base.connection
  end
    
  def execute
    round
    case self.actions_type_id
    when Togabou::ACTIONS_TYPE_DI
      execute_di
    when Togabou::ACTIONS_TYPE_PORT_DIV
      execute_port_div
    when Togabou::ACTIONS_TYPE_TOT_DIV
      execute_tot_div
    when Togabou::ACTIONS_TYPE_FX_DIFF
      execute_fx_diff
    when Togabou::ACTIONS_TYPE_MAN_SELL
      execute_man_sell
    when Togabou::ACTIONS_TYPE_MAN_BUY
      execute_man_buy
    when Togabou::ACTIONS_TYPE_TOT_CI
      execute_tot_ci
    when Togabou::ACTIONS_TYPE_PAID
      execute_paid
    when Togabou::ACTIONS_TYPE_SAVINGS
      execute_savings
    when Togabou::ACTIONS_TYPE_TAX
      execute_tax
    when Togabou::ACTIONS_TYPE_A_OWE_PORT
      execute_owe_port
    when Togabou::ACTIONS_TYPE_E_SET_AMEX_CX
      execute_set_balance( Togabou::BALANCES_AMEX_CX )  
    when Togabou::ACTIONS_TYPE_E_SET_CAPITAL_ONE
      execute_set_balance( Togabou::BALANCES_CAPITAL_ONE )  
    when Togabou::ACTIONS_TYPE_E_SET_HSBC
      execute_set_balance( Togabou::BALANCES_HSBC )  
    when Togabou::ACTIONS_TYPE_E_SET_HSBC_VISA
      execute_set_balance( Togabou::BALANCES_HSBC_VISA )  
    when Togabou::ACTIONS_TYPE_E_SET_VIRTUALBANK
      execute_set_balance( Togabou::BALANCES_VIRTUALBANK )  
    when Togabou::ACTIONS_TYPE_E_SET_GS
      execute_set_balance( Togabou::BALANCES_GS )    
    when Togabou::ACTIONS_TYPE_E_SET_GS_IRA
      execute_set_balance( Togabou::BALANCES_GS_IRA )    
    when Togabou::ACTIONS_TYPE_C_PAID
      execute_c_paid
    else
      raise ArgumentError, sprintf( "Unknown actions_type_id %s", self.actions_type_id ) , caller
    end
    if self.actions_type_id <= Togabou::ACTIONS_TYPE_LAST_SAVED
      save 
    end
    history_balances
  end

  def undo
    round
    case self.actions_type_id
    when Togabou::ACTIONS_TYPE_DI
      undo_di
    when Togabou::ACTIONS_TYPE_PORT_DIV
      undo_port_div
    when Togabou::ACTIONS_TYPE_TOT_DIV
        undo_tot_div
    when Togabou::ACTIONS_TYPE_MAN_SELL
      undo_man_sell
    when Togabou::ACTIONS_TYPE_MAN_BUY
      undo_man_buy
    when Togabou::ACTIONS_TYPE_TOT_CI
      undo_tot_ci
    when Togabou::ACTIONS_TYPE_PAID
      undo_paid
    when Togabou::ACTIONS_TYPE_SAVINGS
      undo_savings
    when Togabou::ACTIONS_TYPE_TAX
      undo_tax
    when Togabou::ACTIONS_TYPE_A_OWE_PORT
      undo_owe_port
    else
      raise ArgumentError, sprintf( "Unknown actions_type_id %s", self.actions_type_id ) , caller
    end
    destroy
    history_balances
  end
  
  def round
    if self.value1 != nil
      self.value1 = self.value1.round(2)
    end
    if self.value2 != nil
      self.value2 = self.value2.round(2)
    end
    if self.value3 != nil
      self.value3 = self.value3.round(2)
    end
    if self.value4 != nil
      self.value4 = self.value4.round(2)
    end
    if self.value5 != nil
      self.value5 = self.value5.round(2)
    end
  end
    
  # Debt Infusion
  def execute_di
    total_capital_final = get_total_capital_balance + self.value1
    xTC_final = get_latest_index_rotc / total_capital_final
    debt_final = get_debt + self.value1
    cash_final = get_cash_total + self.value1
    set_cash_total( cash_final )
    set_debt( debt_final )
    set_divisor_rotc( xTC_final )
    set_total_capital_balance( total_capital_final )
  end
  
  def execute_port_div
    cash_final = get_cash_portfolio + self.value1
    set_cash_portfolio( cash_final )
  end

  def execute_tot_div
    cash_final = get_cash_total + self.value1
    set_cash_total( cash_final )
  end
  
  def execute_fx_diff
    amount = self.value2 - ( self.value1 / Togabou::HKD_FX ) # USD I actually got minus what HKD was carried at
    set_cash_total( get_cash_total + amount )
  end
  
  def execute_man_buy
    execute_man_txn( 1 )
  end
    
  def execute_man_sell
    execute_man_txn( -1 )
  end
  
  def execute_man_txn( side )
    amount = self.value1 * side
    managed_final = get_managed_balance + amount
    xM_final = get_latest_index_401k / managed_final 
    value_final = get_symbol_value( self.symbol ) + amount
    set_divisor_401k( xM_final )
    set_symbol_value( self.symbol, value_final )
    cash_final = get_cash_total - amount
    set_managed_balance( managed_final )
    set_cash_total( cash_final )
  end
  
  def execute_tot_ci
    total_capital_final = get_total_capital_balance + self.value1
    xTC_final = get_latest_index_rotc / total_capital_final
    total_equity_final = get_total_equity_balance + self.value1
    xE_final = get_latest_index_roe / total_equity_final
    cash_final = get_cash_total + self.value1
    set_divisor_rotc( xTC_final )
    set_divisor_roe( xE_final )
    set_total_capital_balance( total_capital_final )
    set_total_equity_balance( total_equity_final )
    set_cash_total( cash_final )
  end

  def execute_paid
    set_paid( get_paid + self.value1 )
  end
 
  def execute_savings
    set_savings( get_savings + self.value1 )
  end

  def execute_tax
    set_tax( get_tax + self.value1 )
  end
  
  def execute_owe_port
    set_owe_port( get_owe_port + self.value1 )
  end
  
  def execute_set_balance( balance_type )
    fx_rate = 1
    if balance_type == Togabou::BALANCES_AMEX_CX || balance_type == Togabou::BALANCES_HSBC || balance_type == Togabou::BALANCES_HSBC_VISA
      fx_rate = Togabou::HKD_FX
    end
    set_balance( self.value1 / fx_rate, balance_type )
  end
    
  def execute_c_paid
    salary_usd = self.value1 / Togabou::HKD_FX 
    orso1_usd = self.value2 / Togabou::HKD_FX
    orso2_usd = self.value3 / Togabou::HKD_FX
    tax_usd = salary_usd * Togabou::TAX_RATE
    
    # Book Salary - Paid
    action = Action.new( date: self.date, actions_type_id: Togabou::ACTIONS_TYPE_PAID, value1: salary_usd )
    action.execute

    # Book Orso 1 - Paid    
    action = Action.new( date: self.date, actions_type_id: Togabou::ACTIONS_TYPE_PAID, value1: orso1_usd )
    action.execute

    # Book Orso 2 - Paid    
    action = Action.new( date: self.date, actions_type_id: Togabou::ACTIONS_TYPE_PAID, value1: orso2_usd )
    action.execute
    
    # Book Tax
    action = Action.new( date: self.date, actions_type_id: Togabou::ACTIONS_TYPE_TAX, value1: tax_usd )
    action.execute

    # DI Tax
    action = Action.new( date: self.date, actions_type_id: Togabou::ACTIONS_TYPE_DI, value1: tax_usd )
    action.execute

    # Add Tax to Owe Port
    action = Action.new( date: self.date, actions_type_id: Togabou::ACTIONS_TYPE_A_OWE_PORT, value1: tax_usd )
    action.execute

    # Book Orso - Savings
    action = Action.new( date: self.date, actions_type_id: Togabou::ACTIONS_TYPE_SAVINGS, value1: orso1_usd + orso2_usd )
    action.execute

    # CI Orso
    action = Action.new( date: self.date, actions_type_id: Togabou::ACTIONS_TYPE_TOT_CI, value1: orso1_usd + orso2_usd )
    action.execute
    
    # Buy Managed for both ORSO's
    action = Action.new( date: self.date, actions_type_id: Togabou::ACTIONS_TYPE_MAN_BUY, value1: orso1_usd, symbol: "Dragons" )
    action.execute
    action = Action.new( date: self.date, actions_type_id: Togabou::ACTIONS_TYPE_MAN_BUY, value1: orso2_usd, symbol: "GlBonds" )
    action.execute
  end
  
  def undo_di
    total_capital_final = get_total_capital_balance - self.value1
    xTC_final = get_latest_index_rotc / total_capital_final
    debt_final = get_debt - self.value1
    cash_final = get_cash_total - self.value1
    owe_port_final = get_owe_port - self.value1
    set_cash_total( cash_final )
    set_debt( debt_final )
    set_divisor_rotc( xTC_final )
    set_owe_port( owe_port_final )
    set_total_capital_balance( total_capital_final )
  end
  
  def undo_port_div
    cash_final = get_cash_portfolio - self.value1
    set_cash_portfolio( cash_final )
  end
  
  def undo_tot_div
    cash_final = get_cash_total - self.value1
    set_cash_total( cash_final )
  end
  
  def undo_fx_diff
    amount = self.value2 - ( self.value1 / Togabou::HKD_FX ) # USD I actually got minus what HKD was carried at
    set_cash_total( get_cash_total - amount )
  end
  
  def undo_man_buy
    execute_man_txn( -1 )
  end
    
  def undo_man_sell
    execute_man_txn( 1 )
  end
 
  def undo_tot_ci
    total_capital_final = get_total_capital_balance - self.value1
    xTC_final = get_latest_index_rotc / total_capital_final
    total_equity_final = get_total_equity_balance - self.value1
    xE_final = get_latest_index_roe / total_equity_final
    cash_final = get_cash_total - self.value1
    set_divisor_rotc( xTC_final )
    set_divisor_roe( xE_final )
    set_total_capital_balance( total_capital_final )
    set_total_equity_balance( total_equity_final )
    set_cash_total( cash_final )
  end

  def undo_paid
    set_paid( get_paid - self.value1 )
  end
    
  def undo_savings
    set_savings( get_savings - self.value1 )
  end

  def undo_tax
    set_tax( get_tax - self.value1 )
  end
  
  def undo_owe_port
    set_owe_port( get_owe_port - self.value1 )
  end
  
  # DB Read Methods
  
  def get_total_equity_balance
    get_scalar( "select * from balances where type=12" )
  end
    
  def get_total_capital_balance
    get_scalar( "select * from balances where type=18" )
  end

  def get_portfolio_balance
    get_scalar( "select * from balances where type=13" )
  end
    
  def get_managed_balance
    get_scalar( "select * from balances where type=14" )
  end
      
  def get_latest_index_rotc
    get_scalar( "select * from index_history where type=3 and date = (select max(date) from index_history where type=3)" )
  end
  
  def get_latest_index_roe
    get_scalar( "select * from index_history where type=2 and date = (select max(date) from index_history where type=2)" )
  end
  
  def get_latest_index_401k
    get_scalar( "select * from index_history where type=4 and date = (select max(date) from index_history where type=4)" )
  end
  
  def get_latest_index_portfolio
    get_scalar( "select * from index_history where type=1 and date = (select max(date) from index_history where type=1)" )
  end
  
  def get_debt
    get_scalar( "select * from portfolio where symbol='DEBT' and type=3" )
  end
  
  def get_cash_total
    get_scalar( "select * from portfolio where symbol='CASH' and type=3" )
  end
  
  def get_owe_port
    get_scalar( "select * from balances where type=7" )
  end

  def get_cash_portfolio
    get_scalar( "select * from portfolio where symbol='CASH' and type=1" )
  end
  
  def get_symbol_value( symbol )
    get_scalar( sprintf( "select * from portfolio where symbol = '%s'", symbol ) )
  end 

  def get_paid
    get_scalar( "select * from balances where type=15" )
  end
  
  def get_tax
    get_scalar( "select * from balances where type=16" )
  end

  def get_savings
    get_scalar( "select * from balances where type=17" )
  end
  
  def get_owe_port
    get_scalar( "select * from balances where type=7" )
  end
  
  def get_scalar( sql )
    res = @conn.execute( sql )
    if res == nil or res.first == nil
      0.to_f
    else
      res.first['value'].to_f
    end 
  end
  
  # DB Write Methods
  
  def set_cash_total( value )
    @conn.execute( sprintf( "update portfolio set value=%.02f where symbol='CASH' and type=3", value.to_f ) )
  end
  
  def set_debt( value )
    @conn.execute( sprintf( "update portfolio set value=%.02f where symbol='DEBT' and type=3", value.to_f ) )
  end
  
  def set_divisor_roe( value )
    @conn.execute( sprintf( "update divisors set value=%s where type=2", value.to_s ) )
  end
      
  def set_divisor_rotc( value )
    @conn.execute( sprintf( "update divisors set value=%s where type=3", value.to_s ) )
  end
  
  def set_divisor_401k( value )
    @conn.execute( sprintf( "update divisors set value=%s where type=4", value.to_s ) )
  end
  
  def set_divisor_self( value )
    @conn.execute( sprintf( "update divisors set value=%s where type=1", value.to_s ) )
  end

  def set_owe_port( value )
    set_balance( value, 7 )
  end  
  
  def set_total_equity_balance( value )
    set_balance( value, 12 )
  end
  
  def set_total_capital_balance( value )
    set_balance( value, 18 )
  end

  def set_managed_balance( value )
    set_balance( value, 14 )
  end

  def set_portfolio_balance( value )
    set_balance( value, 13 )
  end
  
  def set_cash_portfolio( value )
    @conn.execute( sprintf( "update portfolio set value=%.02f where symbol='CASH' and type=1", value.to_f ) )
  end
   
  def set_symbol_value( symbol, value )
    @conn.execute( sprintf( "update portfolio set value=%.02f where symbol='%s'", value.to_f, symbol ) )
  end

  def set_paid( value )
    set_balance( value, 15 )
  end
    
  def set_tax( value )
    set_balance( value, 16 )
  end

  def set_savings( value )
    set_balance( value, 17 )
  end

  def set_owe_port( value )
    set_balance( value, 7 )
  end
  
  def set_balance( value, balance_type )
    @conn.execute( sprintf( "update balances set value=%.02f where type=%s", value.to_f, balance_type.to_s ) )
  end

  def history_balances
    # Update balances_history with today's values
    @conn.execute( "delete from balances_history where date=current_date" )
    @conn.execute( "insert into balances_history (select current_date, type, value from balances)" )
  end
               
end
