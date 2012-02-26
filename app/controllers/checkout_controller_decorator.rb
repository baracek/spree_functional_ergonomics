CheckoutController.class_eval do
  def edit
    if session[:admin_order_edit] == nil or session[:admin_order_edit] == false
      respond_with( @order )
    else
      session.delete(:admin_order_edit)
      redirect_to edit_admin_order_path( @order )
    end
  end
end