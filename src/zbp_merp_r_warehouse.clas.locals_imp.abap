CLASS lhc_zmerp_r_warehouse DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
          REQUEST requested_authorizations FOR Warehouse
        RESULT result,
      validateMandatoryFields FOR VALIDATE ON SAVE
        IMPORTING keys FOR Warehouse~validateMandatoryFields.
ENDCLASS.

CLASS lhc_zmerp_r_warehouse IMPLEMENTATION.

  METHOD get_global_authorizations.

  ENDMETHOD.

  METHOD validateMandatoryFields.

    READ ENTITIES OF zmerp_r_warehouse IN LOCAL MODE
      ENTITY Warehouse
      FIELDS ( WarehouseName CompanyCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_warehouses).

    LOOP AT lt_warehouses REFERENCE INTO DATA(lr_whse).

      DATA(lv_has_error) = abap_false.

      APPEND VALUE #( %tky        = lr_whse->%tky
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-warehouse.

      " Validate Warehouse Name
      IF lr_whse->WarehouseName IS INITIAL.

        lv_has_error = abap_true.

        APPEND VALUE #( %tky                   = lr_whse->%tky
                        %state_area           = 'VALIDATE_MANDATORY'
                        %msg                  = NEW zcm_merp_messages(
                                                  textid   = zcm_merp_messages=>enter_warehouse_name
                                                  severity = if_abap_behv_message=>severity-error )
                        %element-WarehouseName = if_abap_behv=>mk-on ) TO reported-warehouse.

      ENDIF.

      " Validate Company Code
      IF lr_whse->CompanyCode IS INITIAL.

        lv_has_error = abap_true.

        APPEND VALUE #( %tky                  = lr_whse->%tky
                        %state_area           = 'VALIDATE_MANDATORY'
                        %msg                  = NEW zcm_merp_messages(
                                                  textid   = zcm_merp_messages=>enter_company_code
                                                  severity = if_abap_behv_message=>severity-error )
                        %element-CompanyCode  = if_abap_behv=>mk-on ) TO reported-warehouse.

      ENDIF.

      IF lv_has_error = abap_true.
        APPEND VALUE #( %tky = lr_whse->%tky ) TO failed-warehouse.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
