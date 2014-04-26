
class Txn
  attr_accessor :date
  attr_accessor :amount
  attr_accessor :description
  attr_accessor :type
  attr_accessor :source
  def initialize( date, amount, description, type, source )
    @date = date
    @amount = amount
    @description = description
    @type = type
    @source = source
  end
end

class Balance
  attr_accessor :type
  attr_accessor :description
  attr_accessor :value
  attr_accessor :recon_cash
  attr_accessor :recon_budget_pos
  attr_accessor :recon_budget_neg

  def recon_cash
    ! [false, nil, 'f'].include?( @recon_cash )
  end

  def recon_budget_pos
    ! [false, nil, 'f'].include?( @recon_budget_pos )
  end

  def recon_budget_neg
    ! [false, nil, 'f'].include?( @recon_budget_neg )
  end

  def initialize( type, description, value, recon_cash, recon_budget_pos, recon_budget_neg )
    @type = type.to_i
    @description = description
    @value = value.to_f
    @recon_cash = recon_cash
    @recon_budget_pos = recon_budget_pos
    @recon_budget_neg = recon_budget_neg
  end
end

class Accounts
  attr_accessor :date
  attr_accessor :balances
  attr_accessor :txns
  
  def initialize(date = nil)
    conn = ActiveRecord::Base.connection
   
    # If no date is passed in, use max date
    date_sql = "select max(b.date) date from balances_history b"
    if date != nil and date != ""
      date_sql += " where b.date <= '" + date.to_s(:db) + "'"
    end
    res = conn.execute( date_sql ) 
    @date = Date.parse( res.first['date'] )
    
    @balances = Array.new
    @txns = Array.new
    conn = ActiveRecord::Base.connection
    res = conn.execute( sprintf( "select h.type, b.description, h.value, b.recon_cash, b.recon_budget_pos, b.recon_budget_neg 
    from balances b, balances_history h 
    where h.date='%s' and
      b.type = h.type
    order by value desc", @date.to_s(:db) ) )
    res.values().each do |row|
      @balances << Balance.new( row[0], row[1], row[2], row[3], row[4], row[5] )
    end
    res = conn.execute( "select s.date, s.amount, s.description, t.description, b.description from spending s, spending_types t, balances b where 
	s.date > DATE 'today' - 31 and
	s.type = t.type and
	s.source = b.type
order by s.date desc" )
    res.values().each do |row|
      @txns << Txn.new( row[0], row[1], row[2], row[3], row[4] )
    end
    date = "01/01/" + @date.year.to_s
    if @date.month == 1 && @date.day == 1
      date = "01/01/" + (@date.year - 1).to_s
    end
  end
  
  def get_balance_value( type )
    balance = self.balances.find {|x| x.type == type}
    balance.value
  end

  def balances_recon_cash
    ret = self.balances.collect {|x| if x.recon_cash == true then x else nil end}
    ret.compact!
  end

  def total_cash
    total = balances_recon_cash.inject(0){|sum,x| sum += x.value}
    total.to_f
  end
  
  def balances_recon_budget_pos
    ret = self.balances.collect {|x| if x.recon_budget_pos == true then x else nil end}
    ret.compact!
  end
  
  def total_budget_pos
    balances_recon_budget_pos.inject(0){|sum,x| sum += x.value}
  end

  def balances_recon_budget_neg
    ret = self.balances.collect {|x| if x.recon_budget_neg == true then x else nil end}
    ret.compact!
  end

  def total_budget_neg
    balances_recon_budget_neg.inject(0){|sum,x| sum += x.value}
  end

  def fumi_budget
    total_budget_pos - total_budget_neg
  end
end
