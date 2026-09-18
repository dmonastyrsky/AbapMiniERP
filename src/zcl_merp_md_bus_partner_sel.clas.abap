CLASS zcl_merp_md_bus_partner_sel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_merp_md_bus_partner_sel.

  PRIVATE SECTION.
    METHODS prepare_keys
      IMPORTING it_keys        TYPE zif_merp_md_bus_partner_sel=>tt_partner_keys
      RETURNING VALUE(rt_keys) TYPE zif_merp_md_bus_partner_sel=>tt_partner_keys.
ENDCLASS.

CLASS zcl_merp_md_bus_partner_sel IMPLEMENTATION.

  METHOD zif_merp_md_bus_partner_sel~read_partner.
    IF iv_partner_code IS INITIAL.
      RAISE EXCEPTION TYPE zcx_merp_master_data
        EXPORTING
          textid   = zcx_merp_master_data=>business_partner_not_found
          attr1    = CONV string( iv_partner_code )
          severity = if_abap_behv_message=>severity-error.
    ENDIF.

    DATA(lt_partners) = zif_merp_md_bus_partner_sel~read_partners(
      VALUE #( ( PartnerCode = iv_partner_code ) )
    ).

    ASSIGN lt_partners[ PartnerCode = iv_partner_code ] TO FIELD-SYMBOL(<ls_detail>).
    IF sy-subrc = 0.
      rs_partner = <ls_detail>.
    ELSE.
      RAISE EXCEPTION TYPE zcx_merp_master_data
        EXPORTING
          textid   = zcx_merp_master_data=>business_partner_not_found
          attr1    = CONV string( iv_partner_code )
          severity = if_abap_behv_message=>severity-error.
    ENDIF.
  ENDMETHOD.

  METHOD zif_merp_md_bus_partner_sel~read_partners.
    DATA(lt_clean_keys) = prepare_keys( it_partner_keys ).
    IF lt_clean_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT *
      FROM zmerp_r_bus_partner
      FOR ALL ENTRIES IN @lt_clean_keys
      WHERE PartnerCode = @lt_clean_keys-PartnerCode
      INTO TABLE @rt_partners.
  ENDMETHOD.

  METHOD zif_merp_md_bus_partner_sel~validate_partners.
    DATA(lt_clean_keys) = prepare_keys( it_partner_keys ).
    IF lt_clean_keys IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_existing) = zif_merp_md_bus_partner_sel~read_partners( lt_clean_keys ).

    LOOP AT lt_clean_keys INTO DATA(ls_key).
      IF NOT line_exists( lt_existing[ PartnerCode = ls_key-PartnerCode ] ).
        INSERT ls_key INTO TABLE rt_invalid_keys.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD prepare_keys.
    rt_keys = it_keys.
    DELETE rt_keys WHERE PartnerCode IS INITIAL.
    SORT rt_keys BY PartnerCode.
    DELETE ADJACENT DUPLICATES FROM rt_keys COMPARING PartnerCode.
  ENDMETHOD.

ENDCLASS.
