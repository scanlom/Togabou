require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Togabou
   HKD_FX = 7.77
   JPY_FX = 108.34
   TAX_RATE = 0.25
   DIV_GROWTH = 0.0957
 
   PORTFOLIOS_SELF    = 1
   PORTFOLIOS_MANAGED = 2
   PORTFOLIOS_PLAY    = 5

   CONFIDENCE_HIGH    = "HIGH"
   CONFIDENCE_MEDIUM  = "MEDIUM"
   CONFIDENCE_LOW     = "LOW"
   CONFIDENCE_NONE    = "NONE"
    
   BALANCES_AMEX_CX    = 1
   BALANCES_CAPITAL_ONE = 2
   BALANCES_HSBC       = 3
   BALANCES_HSBC_VISA  = 4
   BALANCES_VIRTUALBANK = 5
   BALANCES_JPY        = 6
   BALANCES_GS         = 9
   BALANCES_GS_HKD     = 10
   BALANCES_GS_IRA     = 11
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
   ACTIONS_TYPE_L_PLAY_DIV         = 19
   ACTIONS_TYPE_L_PLAY_CI          = 20
   ACTIONS_TYPE_L_PLAY_BUY         = 21
   ACTIONS_TYPE_L_PLAY_SELL        = 22
   ACTIONS_TYPE_LAST_SAVED         = 49
   ACTIONS_TYPE_E_SET_AMEX_CX      = 50
   ACTIONS_TYPE_E_SET_CAPITAL_ONE  = 51
   ACTIONS_TYPE_E_SET_HSBC         = 52
   ACTIONS_TYPE_E_SET_HSBC_VISA    = 53
   ACTIONS_TYPE_E_SET_VIRTUALBANK  = 54
   ACTIONS_TYPE_E_SET_GS           = 55
   ACTIONS_TYPE_E_SET_GS_IRA       = 56
   ACTIONS_TYPE_E_SET_GS_HKD       = 57
   ACTIONS_TYPE_E_SET_SYMBOL_VALUE_HKD = 58
   ACTIONS_TYPE_E_SET_JPY          = 59
   ACTIONS_TYPE_C_PAID             = 70
     
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
