CLASS zcl_merp_md_comp_code_sel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_merp_md_comp_code_sel.
ENDCLASS.

CLASS zcl_merp_md_comp_code_sel IMPLEMENTATION.

  METHOD zif_merp_md_comp_code_sel~read_company.
    IF iv_company_code IS INITIAL.
      RAISE EXCEPTION TYPE zcx_merp_master_data
        EXPORTING
          textid   = zcx_merp_master_data=>company_code_not_found
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
    IF it_company_keys IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_local) = it_company_keys.
    DELETE lt_local WHERE CompanyCode IS INITIAL.
    SORT lt_local BY CompanyCode.
    DELETE ADJACENT DUPLICATES FROM lt_local COMPARING CompanyCode.

    IF lt_local IS INITIAL.
      RETURN.
    ENDIF.

    SELECT *
      FROM zmerp_r_company_code
      FOR ALL ENTRIES IN @lt_local
      WHERE CompanyCode = @lt_local-CompanyCode
      INTO TABLE @rt_companies.
  ENDMETHOD.


  METHOD zif_merp_md_comp_code_sel~validate_companies.
    IF it_company_keys IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_existing) = zif_merp_md_comp_code_sel~read_companies( it_company_keys ).

    LOOP AT it_company_keys INTO DATA(ls_key) WHERE CompanyCode IS NOT INITIAL.
      IF NOT line_exists( lt_existing[ CompanyCode = ls_key-CompanyCode ] ).
        INSERT ls_key INTO TABLE rt_invalid_keys.
      ENDIF.
    ENDLOOP.

    SORT rt_invalid_keys BY CompanyCode.
    DELETE ADJACENT DUPLICATES FROM rt_invalid_keys COMPARING CompanyCode.
  ENDMETHOD.

ENDCLASS.

