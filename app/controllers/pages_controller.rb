require 'accounts.rb'
require 'assets.rb'

class PagesController < ApplicationController

  def get_accounts
    Accounts.new
  end
  def get_assets
    Assets.new
  end

  def get_chart_roe
    conn = ActiveRecord::Base.connection
    data = Array.new
    res = conn.execute( "select date, value from index_history where type = 2 order by date asc" )
    res.values().each do |row|
      point = Array.new
      point << DateTime.parse(row[0]).to_f*1000
      point << row[1].to_f
      data << point
    end
    LazyHighCharts::HighChart.new('area') do |f|
      f.title({:text => "ROE"})
      f.options[:xAxis][:type] = "datetime"
      f.options[:chart][:zoomType] = "x"
      f.options[:plotOptions][:area] = {
        :fillColor => {
                        :linearGradient => { :x1 => 0, :y1=> 0, :x2=> 0, :y2=> 1},
                        :stops => [
                            [0, "#4169E1"],
                            [1, "#FFFFFF"]
                        ]
                    },
        :lineWidth => 1, 
        :marker => {:enabled => false},
        :shadow => false
      } 
      f.series(:type => 'area', :name=> 'ROE',:data=> data)
    end
  end

  def get_chart_portfolio
    conn = ActiveRecord::Base.connection
    data = Array.new
    res = conn.execute( "select date, value from index_history where type = 1 order by date asc" )
    res.values().each do |row|
      point = Array.new
      point << DateTime.parse(row[0]).to_f*1000
      point << row[1].to_f
      data << point
    end
    LazyHighCharts::HighChart.new('area') do |f|
      f.title({:text => "Portfolio"})
      f.options[:xAxis][:type] = "datetime"
      f.options[:chart][:zoomType] = "x"
      f.options[:plotOptions][:area] = {
        :fillColor => {
                        :linearGradient => { :x1 => 0, :y1=> 0, :x2=> 0, :y2=> 1},
                        :stops => [
                            [0, "#4169E1"],
                            [1, "#FFFFFF"]
                        ]
                    },
        :lineWidth => 1,
        :marker => {:enabled => false},
        :shadow => false
      }
      f.series(:type => 'area', :name=> 'Portfolio',:data=> data)
    end
  end

  def get_chart_managed
    conn = ActiveRecord::Base.connection
    data = Array.new
    res = conn.execute( "select date, value from index_history where type = 4 order by date asc" )
    res.values().each do |row|
      point = Array.new
      point << DateTime.parse(row[0]).to_f*1000
      point << row[1].to_f
      data << point
    end
    LazyHighCharts::HighChart.new('area') do |f|
      f.title({:text => "Managed"})
      f.options[:xAxis][:type] = "datetime"
      f.options[:chart][:zoomType] = "x"
      f.options[:plotOptions][:area] = {
        :fillColor => {
                        :linearGradient => { :x1 => 0, :y1=> 0, :x2=> 0, :y2=> 1},
                        :stops => [
                            [0, "#4169E1"],
                            [1, "#FFFFFF"]
                        ]
                    },
        :lineWidth => 1,
        :marker => {:enabled => false},
        :shadow => false
      }
      f.series(:type => 'area', :name=> 'Managed',:data=> data)
    end
  end
end
