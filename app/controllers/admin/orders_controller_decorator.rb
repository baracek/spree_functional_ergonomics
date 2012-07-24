Admin::OrdersController.class_eval do
  def add_product
    session.delete(:admin_order_checkout)
    @order = Order.find_by_number( params[:id] )
    session[:order_id] = @order ? @order.id : nil
    session[:admin_order_edit] = true
    redirect_to( root_path )
  end
  
  def update
    return_path = nil
    load_order
    @order.line_items.each do |li_to_update|
      li_to_update.accessible = [:price]
    end
    if @order.update_attributes(params[:order]) && @order.line_items.present?
      unless @order.complete?
      
        if params[:order].key?(:email)
          shipping_method = @order.available_shipping_methods(:front_end).first
          if shipping_method
            @order.shipping_method = shipping_method
            @order.create_shipment!
            return_path = edit_admin_order_shipment_path(@order, @order.shipment)
          else
            flash[:error] = t('errors.messages.no_shipping_methods_available')
            return_path = user_admin_order_path(@order)
          end
        else
          return_path = user_admin_order_path(@order)
        end
        
      else
        return_path = admin_order_path(@order)
      end
    else
      @order.errors.add(:line_items, t('errors.messages.blank'))
    end
    @order.line_items.each do |li_to_update|
      li_to_update.accessible = nil
    end
    
    respond_with(@order) do |format|
      format.html do
        if return_path
          redirect_to return_path
        else
          render :action => :edit
        end
      end
    end
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