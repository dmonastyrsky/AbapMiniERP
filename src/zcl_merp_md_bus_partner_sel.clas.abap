CLASS zcl_merp_md_bus_partner_sel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_merp_md_bus_partner_sel.

  PRIVATE SECTION.
    TYPES tt_partner_keys_unique TYPE HASHED TABLE OF zif_merp_md_bus_partner_sel=>ty_partner_key
                                      WITH UNIQUE KEY PartnerCode.

    "! Cleanses, sorts and removes duplicates from input keys
    "! @parameter it_keys | Raw table of keys
    "! @parameter rt_keys | Processed clean table of keys
    METHODS prepare_keys
      IMPORTING it_keys        TYPE zif_merp_md_bus_partner_sel=>tt_partner_keys
      RETURNING VALUE(rt_keys) TYPE zif_merp_md_bus_partner_sel=>tt_partner_keys.
ENDCLASS.

CLASS zcl_merp_md_bus_partner_sel IMPLEMENTATION.

  METHOD zif_merp_md_bus_partner_sel~read_partner.
    DATA(lt_partners) = zif_merp_md_bus_partner_sel~read_partners(
      VALUE #( ( PartnerCode = iv_partner_code ) )
    ).

    " An initial code is dropped by prepare_keys, so this one check also covers empty input
    TRY.
        rs_partner = lt_partners[ PartnerCode = iv_partner_code ].
      CATCH cx_sy_itab_line_not_found.
        RAISE EXCEPTION TYPE zcx_merp_md
          EXPORTING
            textid   = zcx_merp_md=>business_partner_not_found
            attr1    = CONV string( iv_partner_code )
            severity = if_abap_behv_message=>severity-error.
    ENDTRY.
  ENDMETHOD.


  METHOD zif_merp_md_bus_partner_sel~read_partners.
    DATA(lt_clean_keys) = prepare_keys( it_partner_keys ).
    IF lt_clean_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM zmerp_r_bus_partner AS bp
      INNER JOIN @lt_clean_keys AS keys ON bp~PartnerCode = keys~PartnerCode
      FIELDS bp~*
      INTO TABLE @rt_partners.
  ENDMETHOD.

  METHOD zif_merp_md_bus_partner_sel~validate_partners.
    DATA lt_existing_keys TYPE tt_partner_keys_unique.

    DATA(lt_clean_keys) = prepare_keys( it_partner_keys ).
    IF lt_clean_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT bp~PartnerCode
      FROM zmerp_r_bus_partner AS bp
      INNER JOIN @lt_clean_keys AS keys ON bp~PartnerCode = keys~PartnerCode
      INTO TABLE @lt_existing_keys.

    LOOP AT lt_clean_keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      IF NOT line_exists( lt_existing_keys[ PartnerCode = <ls_key>-PartnerCode ] ).
        INSERT <ls_key> INTO TABLE rt_invalid_keys.
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

