class Research < ApplicationRecord
  belongs_to :stock
  
  attr_accessor :confidence
  
  after_initialize :initialize_members
  def initialize_members
    @confidence = Togabou::CONFIDENCE_NONE
    if self.comment != nil
      if self.comment.include?(Togabou::CONFIDENCE_HIGH)
        @confidence = Togabou::CONFIDENCE_HIGH
      elsif self.comment.include?(Togabou::CONFIDENCE_MEDIUM)
        @confidence = Togabou::CONFIDENCE_MEDIUM
      elsif self.comment.include?(Togabou::CONFIDENCE_LOW)
        @confidence = Togabou::CONFIDENCE_LOW
      end  
    end
  end
end
