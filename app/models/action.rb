class Action < ActiveRecord::Base
  belongs_to :actions_type

  after_initialize :initialize_members
  def initialize_members
    @conn = ActiveRecord::Base.connection
  end
    
  def execute
    case self.actions_type_id
    when Togabou::ACTIONS_TYPE_DI
      execute_di
    when Togabou::ACTIONS_TYPE_PORT_DIV
      execute_port_div
    else
      raise ArgumentError, "Unknown actions_type_id", caller
    end
    save
  end

  def undo
    case self.actions_type_id
    when Togabou::ACTIONS_TYPE_DI
      undo_di
    when Togabou::ACTIONS_TYPE_PORT_DIV
      undo_port_div
    else
      raise ArgumentError, "Unknown actions_type_id", caller
    end
    destroy
  end
    
  # Debt Infusion
  def execute_di
    total_capital_final = get_total_capital_balance + self.value1
    xTC_final = get_latest_index_rotc / total_capital_final
    debt_final = get_debt + self.value1
    cash_final = get_cash_total + self.value1
    owe_port_final = get_owe_port + self.value1
    set_cash_total( cash_final )
    set_debt( debt_final )
    set_divisor_rotc( xTC_final )
    set_owe_port( owe_port_final )
    set_total_capital_balance( total_capital_final )
  end
  
  def execute_port_div
    cash_final = get_cash_portfolio + self.value1
    set_cash_portfolio( cash_final )
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
  
  # DB Read Methods
  
  def get_total_capital_balance
    get_scalar( "select * from balances where type=18" )
  end
      
  def get_latest_index_rotc
    get_scalar( "select * from index_history where type=3 and date = (select max(date) from index_history where type=3)" )
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
    @conn.execute( sprintf( "update portfolio set value=%s where symbol='CASH' and type=3", value.to_s ) )
  end
  
  def set_debt( value )
    @conn.execute( sprintf( "update portfolio set value=%s where symbol='DEBT' and type=3", value.to_s ) )
  end
  
  def set_divisor_rotc( value )
    @conn.execute( sprintf( "update divisors set value=%s where type=3", value.to_s ) )
  end

  def set_owe_port( value )
    @conn.execute( sprintf( "update balances set value=%s where type=7", value.to_s ) )
  end  

  def set_total_capital_balance( value )
    @conn.execute( sprintf( "update balances set value=%s where type=18", value.to_s ) )
  end

  def set_cash_portfolio( value )
    @conn.execute( sprintf( "update portfolio set value=%s where symbol='CASH' and type=1", value.to_s ) )
  end
       
end
