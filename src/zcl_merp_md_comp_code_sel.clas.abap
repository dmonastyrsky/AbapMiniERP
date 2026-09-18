CLASS zcl_merp_md_comp_code_sel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_merp_md_comp_code_sel.

  PRIVATE SECTION.
    METHODS prepare_keys
      IMPORTING it_keys        TYPE zif_merp_md_comp_code_sel=>tt_company_keys
      RETURNING VALUE(rt_keys) TYPE zif_merp_md_comp_code_sel=>tt_company_keys.
ENDCLASS.

CLASS zcl_merp_md_comp_code_sel IMPLEMENTATION.

  METHOD zif_merp_md_comp_code_sel~read_company.
    IF iv_company_code IS INITIAL.
      RAISE EXCEPTION TYPE zcx_merp_master_data
        EXPORTING
          textid   = zcx_merp_master_data=>company_code_not_found
          attr1    = CONV string( iv_company_code )
          severity = if_abap_behv_message=>severity-error.
    ENDIF.

    DATA(lt_companies) = zif_merp_md_comp_code_sel~read_companies(
      VALUE #( ( CompanyCode = iv_company_code ) )
    ).

    ASSIGN lt_companies[ CompanyCode = iv_company_code ] TO FIELD-SYMBOL(<ls_detail>).
    IF sy-subrc = 0.
      rs_company = <ls_detail>.
    ELSE.
      RAISE EXCEPTION TYPE zcx_merp_master_data
        EXPORTING
          textid   = zcx_merp_master_data=>company_code_not_found
          attr1    = CONV string( iv_company_code )
          severity = if_abap_behv_message=>severity-error.
    ENDIF.
  ENDMETHOD.

  METHOD zif_merp_md_comp_code_sel~read_companies.
    DATA(lt_clean_keys) = prepare_keys( it_company_keys ).
    IF lt_clean_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT *
      FROM zmerp_r_company_code
      FOR ALL ENTRIES IN @lt_clean_keys
      WHERE CompanyCode = @lt_clean_keys-CompanyCode
      INTO TABLE @rt_companies.
  ENDMETHOD.

  METHOD zif_merp_md_comp_code_sel~validate_companies.
    DATA(lt_clean_keys) = prepare_keys( it_company_keys ).
    IF lt_clean_keys IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_existing) = zif_merp_md_comp_code_sel~read_companies( lt_clean_keys ).

    LOOP AT lt_clean_keys INTO DATA(ls_key).
      IF NOT line_exists( lt_existing[ CompanyCode = ls_key-CompanyCode ] ).
        INSERT ls_key INTO TABLE rt_invalid_keys.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD prepare_keys.
    rt_keys = it_keys.
    DELETE rt_keys WHERE CompanyCode IS INITIAL.
    SORT rt_keys BY CompanyCode.
    DELETE ADJACENT DUPLICATES FROM rt_keys COMPARING CompanyCode.
  ENDMETHOD.

ENDCLASS.


