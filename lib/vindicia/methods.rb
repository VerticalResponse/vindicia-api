module Vindicia
  API_CLASSES = {
    '4.0' => {
      account: {
        add_children:                         [:accounts],
        decrement_tokens:                     [:token_amounts],
        extend_entitlement_by_interval:       [:account],
        extend_entitlement_to_date:           [:account],
        fetch_by_email:                       [:accounts],
        fetch_by_merchant_account_id:         [:account],
        fetch_by_payment_method:              [:accounts],
        fetch_by_vid:                         [:account],
        fetch_by_web_session_vid:             [:account],
        fetch_credit_history:                 [:credit_event_logs],
        fetch_family:                         [:parent, :child],
        grant_credit:                         [:account],
        grant_entitlement:                    [:account],
        increment_tokens:                     [:token_amounts],
        is_entitled:                          [:entitled],
        make_payment:                         [:transaction, :summary],
        redeem_gift_card:                     [:account, :giftcard],
        remove_children:                      [:result],
        reverse_payment:                      [:result],
        revoke_credit:                        [:account],
        revoke_entitlement:                   [:account],
        stop_auto_billing:                    [:account],
        token_balance:                        [:token_amounts],
        token_transaction:                    [:token_amounts],
        transfer:                             [:merged_account],
        transfer_credit:                      [:result],
        update:                               [:account, :created],
        update_payment_method:                [:account, :validated],
      },
      activity: {
        record:                               [:result]
      },
      address: {
        fetch_by_vid:                         [:address],
        update:                               [:address, :created],
      },
      auto_bill: {
        add_campaign:                         [:autobill],
        add_campaign_to_product:              [:autobill],
        add_charge:                           [:result],
        add_product:                          [:autobill],
        cancel:                               [:autobill, :trasactions, :refunds],
        change_billing_day_of_month:          [:autobill, :next_billing_date, :next_billing_amount, :next_billing_currency],
        delay_billing_by_days:                [:autobill, :next_billing_date, :next_billing_amount, :next_billing_currency],
        delay_billing_to_date:                [:autobill, :next_billing_date, :next_billing_amount, :next_billing_currency],
        fetch_by_account:                     [:autobills],
        fetch_all_credit_history:             [:autobills],
        fetch_by_account_and_product:         [:autobills],
        fetch_by_email:                       [:autobills],
        fetch_by_merchant_auto_bill_id:       [:autobill],
        fetch_by_vid:                         [:autobill],
        fetch_by_web_session_vid:             [:autobill],
        fetch_credit_history:                 [:credit_event_logs],
        fetch_daily_invoice_billings:         [:transactions],
        fetch_delta_since:                    [:autobills],
        fetch_future_rebills:                 [:transactions],
        fetch_invoice:                        [:invoice],
        fetch_invoice_numbers:                [:invoicenum],
        fetch_upgrade_history_by_merchant_auto_bill_id: [:upgrade_history_steps],
        fetch_upgrade_history_by_vid:         [:upgrade_history_steps],
        finalize_pay_pal_auth:                [:autobill, :auth_status],
        grant_credit:                         [:autobill],
        make_payment:                         [:transaction, :summary],
        redeem_gift_card:                     [:autobill, :giftcard],
        remove_product:                       [:autobill],
        reverse_payment:                      [:result],
        revoke_credit:                        [:autobill],
        update:                               [:autobill, :created, :auth_stats, :first_bill_date, :first_bill_amount, :first_billing_currency, :score, :socore_codes],
        upgrade:                              [:autobill, :netcost, :credit, :debit],
        write_off_invoice:                    [:result],
      },
      billing_plan: {
        fetch_all:                            [:billing_plans],
        fetch_by_billing_plan_status:         [:billing_plans],
        fetch_by_merchant_billing_plan_id:    [:billing_plan],
        fetch_by_merchant_entitlement_id:     [:billing_plans],
        fetch_by_vid:                         [:billing_plan],
        update:                               [:billing_plan, :created],
      },
      campaign: {
        activate_campaign:                    [:return],
        activate_code:                        [:return],
        cancel_campaign:                      [:return],
        deactivate_campaign:                  [:return],
        fetch_all_campaigns:                  [:campaign],
        fetch_by_campaign_id:                 [:campaign],
        fetch_by_vid:                         [:campaign],
        retrieve_coupon_codes:                [:coupon_code],
        validate_code:                        [:valid],
      },
      chargeback: {
        fetch_by_account:                     [:chargebacks],
        fetch_by_case_number:                 [:chargebacks],
        fetch_by_merchant_transaction_id:     [:chargebacks],
        fetch_by_status:                      [:status, :page, :page_size],
        fetch_by_status_since:                [:chargebacks],
        fetch_by_reference_number:            [:chargebacks],
        fetch_by_vid:                         [:chargeback],
        fetch_delta:                          [:chargebacks],
        fetch_delta_since:                    [:chargebacks],
        report:                               [:return],
        update:                               [:chargeback, :created]
      },
      diagnostic: {
        get_hello:                            [:server_string],
        put_hello:                            [:result],
        echo_string:                          [:result],
        echo_string_by_proxy:                 [:result],
        get_some_mock_transactions:           [:transactions],
        put_some_mock_transactions:           [:server_string],
        echo_boolean:                         [:server_echo_of_client_boolean, :server_echo_of_client_boolean_as_int],
        echo_date_time:                       [:result],
        echo_mock_activity_fulfillment:       [:result],
        useless_use_of_diagnostic_object:     [:result],
      },
      entitlement: {
        fetch_by_account:                     [:entitlements],
        fetch_by_entitlement_id_and_account:  [:entitlement],
        fetch_delta_since:                    [:entitlements],
      },
      gift_card: {
        reverse:                              [:giftcard],
        status_inquiry:                       [:giftcard],
      },
      name_value_pair: {
        fetch_name_value_names:               [:names],
        fetch_name_value_types:               [:types],
      },
      payment_method: {
        fetch_by_account:                     [:payment_methods],
        fetch_by_merchant_payment_method_id:  [:payment_method],
        fetch_by_vid:                         [:payment_method],
        fetch_by_web_session_vid:             [:payment_method],
        update:                               [:payment_method, :created, :validated, :score, :score_codes, :auth_status],
        validate:                             [:auth_status, :validated, :avs_cvn_policy_evaluation_details, :score, :score_codes],
      },
      payment_provider: {
        data_request:                         [:payment_provider, :request, :response],
        fetch_by_name:                        [:payment_provider],
      },
      product: {
        fetch_all:                            [:products],
        fetch_by_account:                     [:products],
        fetch_by_merchant_entitlement_id:     [:products],
        fetch_by_merchant_product_id:         [:product],
        fetch_by_vid:                         [:product],
        update:                               [:product, :created],
      },
      rate_plan: {
        deduct_event:                         [:result],
        fetch_by_merchant_rate_plan_id:       [:rate_plan],
        fetch_by_vid:                         [:rate_plan],
        fetch_event_by_id:                    [:event],
        fetch_event_by_vid:                   [:event],
        fetch_events:                         [:event],
        fetch_unbilled_events:                [:event],
        fetch_unbilled_rated_units_total:     [:rated_unit_summary],
        record_event:                         [:result],
        reverse_event:                        [:result],
      },
      refund: {
        fetch_by_account:                     [:refunds],
        fetch_by_transaction:                 [:refunds],
        fetch_by_vid:                         [:refund],
        fetch_delta_since:                    [:refunds],
        perform:                              [:refunds],
        report:                               [:refunds],
      },
      token: {
        fetch:                                [:result],
        update:                               [:token],
      },
      transaction: {
        auth:                                 [:transaction, :score, :score_codes],
        auth_capture:                         [:transaction],
        calculate_sales_tax:                  [:transaction, :address_type, :original_address, :corrected_address, :tax_items, :total_tax],
        cancel:                               [:qty_success, :qty_fail, :results],
        capture:                              [:qty_success, :qty_fail, :results],
        fetch_by_account:                     [:transactions],
        fetch_by_autobill:                    [:transactions],
        fetch_by_merchant_transaction_id:     [:transaction],
        fetch_by_payment_method:              [:transactions],
        fetch_by_vid:                         [:transaction],
        fetch_by_web_session_vid:             [:transaction],
        fetch_delta:                          [:transactions, :start_date, :end_date],
        fetch_delta_since:                    [:transactions, :payment_method],
        finalize_pay_pal_auth:                [:transactions],
        report:                               [:result],
        score:                                [:transaction, :score, :score_codes],
      },
      web_session: {
        fetch_by_vid:                         [:session],
        finalize:                             [:session],
#        initialize:                           [:session],
      }
    }
  }
end
