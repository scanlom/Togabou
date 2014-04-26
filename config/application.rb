require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Togabou
  HKD_FX = 7.76
  TAX_RATE = 0.3
  
  BALANCES_AMEX_CX    = 1
  BALANCES_CAPITAL_ONE = 2
  BALANCES_HSBC       = 3
  BALANCES_HSBC_VISA  = 4
  BALANCES_VIRTUALBANK = 5
  BALANCES_TOTAL_ROE  = 12
  BALANCES_PAID       = 15
  BALANCES_TAX        = 16
  BALANCES_SAVINGS    = 17
  
  ACTIONS_TYPE_UNKNOWN  = 0
  ACTIONS_TYPE_PORT_DIV = 1
  ACTIONS_TYPE_TOT_INT  = 2
  ACTIONS_TYPE_PAID     = 3
  ACTIONS_TYPE_TAX      = 4
  ACTIONS_TYPE_SAVINGS  = 5
  ACTIONS_TYPE_DI       = 6
  ACTIONS_TYPE_MAN_BUY  = 7
  ACTIONS_TYPE_TOT_DIV  = 8
  ACTIONS_TYPE_FX_DIFF  = 9 # FX - HKD to USD Difference With Cash
  ACTIONS_TYPE_PORT_CI  = 10
  ACTIONS_TYPE_PORT_BUY = 11
  ACTIONS_TYPE_MAN_DIV_REINVEST   = 12
  ACTIONS_TYPE_MAN_ST_CG_REINVEST = 13
  ACTIONS_TYPE_MAN_LT_CG_REINVEST = 14
  ACTIONS_TYPE_MAN_SELL           = 15
  ACTIONS_TYPE_PORT_SELL          = 16
  ACTIONS_TYPE_TOT_CI             = 17
  ACTIONS_TYPE_A_OWE_PORT         = 18
  ACTIONS_TYPE_E_SET_AMEX_CX      = 50
  ACTIONS_TYPE_E_SET_CAPITAL_ONE  = 51
  ACTIONS_TYPE_E_SET_HSBC         = 52
  ACTIONS_TYPE_E_SET_HSBC_VISA    = 53
  ACTIONS_TYPE_E_SET_VIRTUALBANK  = 54
  ACTIONS_TYPE_LAST_SIMPLE        = 69 # Make sure this is the last non compound action, as only simple actions save
  ACTIONS_TYPE_C_PAID             = 70
          
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
