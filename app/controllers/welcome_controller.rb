require 'assets.rb'

class WelcomeController < ApplicationController
  def index
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
end
