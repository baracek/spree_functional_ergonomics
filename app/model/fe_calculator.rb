class FeCalculator < Calculator
  def compute( object )
    if object.is_a?(Array)
      order = object.first.order
    elsif object.is_a?(Shipment)
      order = object.order
    else
      order = object
    end    
    
    ergocentric_rate = nil
    regular_items = false
    order.line_items.each do |item|
      if item.product and item.product.shipping_category and item.product.shipping_category.name == "ergoCentric"
        ergocentric_rate = item.product.shipping_category.name == "ergoCentric" ? 50.0 : ergocentric_rate
      else
        regular_items = true
      end
    end
    
    if regular_items
      fedex_calculator = Calculator::Fedex::Ground.new()
      fedex_rate = fedex_calculator.compute( order )
    end
    
    rate = fedex_rate
    rate = rate == nil ? ergocentric_rate : ergocentric_rate == nil ? rate : rate + ergocentric_rate
  
    rate
  end
  
  def self.register
    super
    ShippingMethod.register_calculator(self)
  end
  
  def self.description
    "Functional Ergonomics Calculator"
  end  
end
