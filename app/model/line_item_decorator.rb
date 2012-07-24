LineItem.class_eval do
  attr_accessor :accessible
  
  private
  
  def mass_assignment_authorizer
    super + (accessible || [])
  end
end
