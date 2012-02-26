Admin::OrdersController.class_eval do
  def add_product
    session.delete(:admin_order_checkout)
    @order = Order.find_by_number( params[:id] )
    session[:order_id] = @order ? @order.id : nil
    session[:admin_order_edit] = true
    redirect_to( root_path )
  end

  def do_checkout
    session.delete(:admin_order_edit)
    session[:admin_order_checkout] = true
    @order = Order.find_by_number( params[:id] )
    logger.info 'Checking email'
    logger.info @order.email
    if @order.email == nil
      logger.info 'Email is empty'
      if @order.user and not @order.user.anonymous?
        logger.info 'Not anonymous'
        @order.email = @order.user.email
        logger.info @order.user.email
      else
        logger.info 'Anonymous Order'
        @order.email = User.current.email
        logger.info User.current.email
      end
      @order.save
    end
    session[:order_id] = @order ? @order.id : nil
    if @order.state == "cart"
      redirect_to( checkout_path )
    else      
      redirect_to( checkout_state_path(@order.state) )
    end
  end

  def edit
    session.delete(:admin_order_edit)
    session.delete(:admin_order_checkout)
    load_order
    respond_with(@order)
  end
end