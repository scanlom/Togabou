
class Entry
  attr_accessor :date
  attr_accessor :type
  attr_accessor :value
  def initialize( date, type, value )
    @date = date
    @type = type
    @value = value
  end
end

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
  attr_accessor :balances
  attr_accessor :txns
  attr_accessor :entries
  
  def initialize
    @balances = Array.new
    @txns = Array.new
    @entries = Array.new
    conn = ActiveRecord::Base.connection
    res = conn.execute( "select * from balances order by value desc" )
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
    res = conn.execute( sprintf( "select h.date, h.type, h.value1 from history h where 
  h.date > '01/01/%s' and
  h.type = %d
  order by h.date asc", Time.now.year, Togabou::HISTORY_SAVINGS ) )
    res.values().each do |row|
      @entries << Entry.new( row[0], row[1], row[2] )
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
    total_budget_pos + 16432.70 - total_budget_neg
  end
end
