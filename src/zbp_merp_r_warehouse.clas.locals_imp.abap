"! Local behavior handler for Warehouse BO entity.
CLASS lhc_zmerp_r_warehouse DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS:
      c_state_area_mandatory TYPE string VALUE 'VALIDATE_MANDATORY',
      c_state_area_company   TYPE string VALUE 'VALIDATE_COMPANY'.

    "! Evaluates global authorizations for CUD operations.
    "! @parameter requested_authorizations | Mandatory RAP requested authorization flags
    "! @parameter result | Resulting authorization statuses
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
      REQUEST requested_authorizations FOR Warehouse
      RESULT result.

    "! Validates mandatory fields before saving.
    "! @parameter keys | Entity keys for validation
    METHODS validateMandatoryFields FOR VALIDATE ON SAVE
      IMPORTING keys FOR Warehouse~validateMandatoryFields.


    "! Validates the existence of the assigned Company Code.
    "! @parameter keys | Entity keys for validation
    METHODS validateCompanyCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR Warehouse~validateCompanyCode.
    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE Warehouse.

    "! Assigns early numbers for new Warehouse entities.
    "! @parameter entities | Entities requested for creation
    "! @parameter mapped | Mapped keys output structure
    "! @parameter failed | Failed entities output structure
    "! @parameter reported | Reported messages output structure
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Warehouse.

ENDCLASS.

CLASS lhc_zmerp_r_warehouse IMPLEMENTATION.

  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

  METHOD validateMandatoryFields.
    DATA lv_has_error TYPE abap_bool.

    reported-warehouse = VALUE #(
      BASE reported-warehouse
      FOR key IN keys
      ( %tky        = key-%tky
        %state_area = c_state_area_mandatory )
    ).

    READ ENTITIES OF zmerp_r_warehouse IN LOCAL MODE
      ENTITY Warehouse
      FIELDS ( WarehouseName CompanyCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_warehouses).

    LOOP AT lt_warehouses REFERENCE INTO DATA(lr_whse).
      lv_has_error = abap_false.

      IF lr_whse->WarehouseName IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                   = lr_whse->%tky
          %state_area           = c_state_area_mandatory
          %msg                  = NEW zcm_merp_messages(
                                    textid   = zcm_merp_messages=>enter_warehouse_name
                                    severity = if_abap_behv_message=>severity-error )
          %element-WarehouseName = if_abap_behv=>mk-on
        ) TO reported-warehouse.
      ENDIF.

      IF lr_whse->CompanyCode IS INITIAL.
        lv_has_error = abap_true.
        APPEND VALUE #(
          %tky                  = lr_whse->%tky
          %state_area           = c_state_area_mandatory
          %msg                  = NEW zcm_merp_messages(
                                    textid   = zcm_merp_messages=>enter_company_code
                                    severity = if_abap_behv_message=>severity-error )
          %element-CompanyCode  = if_abap_behv=>mk-on
        ) TO reported-warehouse.
      ENDIF.

      IF lv_has_error = abap_true.
        APPEND VALUE #(
          %tky        = lr_whse->%tky
          %fail-cause = if_abap_behv=>cause-unspecific
        ) TO failed-warehouse.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCompanyCode.
    " 1. Clear previous reported error messages for this state area
    reported-warehouse = VALUE #(
      BASE reported-warehouse
      FOR key IN keys
      ( %tky        = key-%tky
        %state_area = c_state_area_company )
    ).

    " 2. Read requested entity instances
    READ ENTITIES OF zmerp_r_warehouse IN LOCAL MODE
      ENTITY Warehouse
      FIELDS ( CompanyCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_warehouses).

    " 3. Define a sorted structure to instantly deduplicate codes in memory
    TYPES: BEGIN OF ty_company_code,
             companycode TYPE zmerp_company_code,
           END OF ty_company_code.

    DATA lt_companies_to_check TYPE SORTED TABLE OF ty_company_code WITH UNIQUE KEY companycode.

    " 4. Collect non-initial company codes (automatically deduplicated by unique key)
    LOOP AT lt_warehouses REFERENCE INTO DATA(lr_whse_src) WHERE CompanyCode IS NOT INITIAL.
      INSERT VALUE #( companycode = lr_whse_src->CompanyCode ) INTO TABLE lt_companies_to_check.
    ENDLOOP.

    IF lt_companies_to_check IS INITIAL.
      RETURN.
    ENDIF.

    " 5. Direct selection into a sorted table to find valid existing records
    DATA lt_existing_db TYPE SORTED TABLE OF ty_company_code WITH UNIQUE KEY companycode.

    SELECT CompanyCode AS companycode
      FROM zmerp_r_company_code WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_companies_to_check
      WHERE CompanyCode = @lt_companies_to_check-companycode
      INTO TABLE @lt_existing_db.

    " 6. Report errors for non-existing entries using built-in key lookup
    LOOP AT lt_warehouses REFERENCE INTO DATA(lr_whse) WHERE CompanyCode IS NOT INITIAL.
      IF NOT line_exists( lt_existing_db[ companycode = lr_whse->CompanyCode ] ).
        APPEND VALUE #(
          %tky        = lr_whse->%tky
          %fail-cause = if_abap_behv=>cause-not_found
        ) TO failed-warehouse.

        APPEND VALUE #(
          %tky                  = lr_whse->%tky
          %state_area           = c_state_area_company
          %msg                  = NEW zcm_merp_messages(
                                    textid   = zcm_merp_messages=>company_code_not_found
                                    attr1    = CONV #( lr_whse->CompanyCode )
                                    severity = if_abap_behv_message=>severity-error )
          %element-CompanyCode  = if_abap_behv=>mk-on
        ) TO reported-warehouse.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD earlynumbering_create.
    IF entities IS INITIAL.
      RETURN.
    ENDIF.

    DATA lv_next_wh_code TYPE zmerp_warehouse_code.

    LOOP AT entities REFERENCE INTO DATA(lr_entity).
      IF lr_entity->WarehouseCode IS INITIAL.
        lv_next_wh_code = zcl_merp_num_range_util=>get_next_warehouse_code_nro( ).

        IF lv_next_wh_code IS NOT INITIAL.
          APPEND VALUE #(
            %cid          = lr_entity->%cid
            %is_draft     = lr_entity->%is_draft
            WarehouseCode = lv_next_wh_code
          ) TO mapped-warehouse.
        ELSE.
          APPEND VALUE #(
            %cid        = lr_entity->%cid
            %is_draft   = lr_entity->%is_draft
            %fail-cause = if_abap_behv=>cause-unspecific
          ) TO failed-warehouse.

          APPEND VALUE #(
            %cid      = lr_entity->%cid
            %is_draft = lr_entity->%is_draft
            %msg      = NEW zcm_merp_messages(
                          textid   = zcm_merp_messages=>warehouse_number_failed
                          severity = if_abap_behv_message=>severity-error )
          ) TO reported-warehouse.
        ENDIF.
      ELSE.
        APPEND VALUE #(
          %cid          = lr_entity->%cid
          %is_draft     = lr_entity->%is_draft
          WarehouseCode = lr_entity->WarehouseCode
        ) TO mapped-warehouse.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD precheck_delete.
  ENDMETHOD.

ENDCLASS.
