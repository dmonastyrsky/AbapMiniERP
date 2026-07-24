CLASS LHC_ZMERP_R_WAREHOUSE DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Warehouse
        RESULT result,
      validateMandatoryFields FOR VALIDATE ON SAVE
            IMPORTING keys FOR Warehouse~validateMandatoryFields,
      validateWarehouseCode FOR VALIDATE ON SAVE
            IMPORTING keys FOR Warehouse~validateWarehouseCode.
ENDCLASS.

CLASS LHC_ZMERP_R_WAREHOUSE IMPLEMENTATION.

  METHOD GET_GLOBAL_AUTHORIZATIONS.

  ENDMETHOD.

  METHOD validateMandatoryFields.
    READ ENTITIES OF zmerp_r_warehouse IN LOCAL MODE
      ENTITY Warehouse
      FIELDS ( WarehouseName CompanyCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_warehouses).

    LOOP AT lt_warehouses INTO DATA(ls_whse).

      APPEND VALUE #( %tky        = ls_whse-%tky
                      %state_area = 'VALIDATE_MANDATORY' ) TO reported-warehouse.

      " Validate Warehouse Name
      IF ls_whse-WarehouseName IS INITIAL.
        APPEND VALUE #( %tky = ls_whse-%tky ) TO failed-warehouse.

        APPEND VALUE #( %tky                  = ls_whse-%tky
                        %state_area           = 'VALIDATE_MANDATORY'
                        %msg                  = NEW zcm_merp_messages(
                                                  textid   = zcm_merp_messages=>enter_warehouse_name
                                                  severity = if_abap_behv_message=>severity-error )
                        %element-WarehouseName = if_abap_behv=>mk-on ) TO reported-warehouse.
      ENDIF.

      " Validate Company Code
      IF ls_whse-CompanyCode IS INITIAL.
        APPEND VALUE #( %tky = ls_whse-%tky ) TO failed-warehouse.

        APPEND VALUE #( %tky                  = ls_whse-%tky
                        %state_area           = 'VALIDATE_MANDATORY'
                        %msg                  = NEW zcm_merp_messages(
                                                  textid   = zcm_merp_messages=>enter_company_code
                                                  severity = if_abap_behv_message=>severity-error )
                        %element-CompanyCode  = if_abap_behv=>mk-on ) TO reported-warehouse.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validateWarehouseCode.
    READ ENTITIES OF zmerp_r_warehouse IN LOCAL MODE
      ENTITY Warehouse
      FIELDS ( WarehouseCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_warehouses).

    LOOP AT lt_warehouses INTO DATA(ls_whse).

      APPEND VALUE #( %tky        = ls_whse-%tky
                      %state_area = 'VALIDATE_EXISTENCE' ) TO reported-warehouse.

      IF ls_whse-WarehouseCode IS NOT INITIAL.

        SELECT SINGLE FROM zmerp_warehouse
          FIELDS warehouse_code
          WHERE warehouse_code = @ls_whse-WarehouseCode
          INTO @DATA(lv_exists).

        IF lv_exists IS NOT INITIAL.
          APPEND VALUE #( %tky = ls_whse-%tky ) TO failed-warehouse.

          APPEND VALUE #( %tky                  = ls_whse-%tky
                          %state_area           = 'VALIDATE_EXISTENCE'
                          %msg                  = NEW zcm_merp_messages(
                                                    textid   = zcm_merp_messages=>warehouse_code_exists
                                                    attr1    = |{ ls_whse-WarehouseCode }|
                                                    severity = if_abap_behv_message=>severity-error )
                          %element-WarehouseCode = if_abap_behv=>mk-on ) TO reported-warehouse.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
