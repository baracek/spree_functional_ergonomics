class SpreeFunctionalErgonomicsHooks < Spree::ThemeSupport::HookListener
  replace :footer_right, :text =>"905.592.1588"

  insert_after :admin_order_edit_form do
    %( <%= button_link_to("Recalculate Taxes And Shipping", do_checkout_admin_order_url(@order)) %>)
  end
end