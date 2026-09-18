INTERFACE zif_merp_md_bus_partner_sel
  PUBLIC.

  TYPES ty_partner TYPE zmerp_r_bus_partner.
  TYPES tt_partners TYPE SORTED TABLE OF ty_partner WITH UNIQUE KEY PartnerCode.

  TYPES: BEGIN OF ty_partner_key,
           PartnerCode TYPE zmerp_r_bus_partner-PartnerCode,
         END OF ty_partner_key,
         tt_partner_keys TYPE STANDARD TABLE OF ty_partner_key WITH EMPTY KEY.

  "! Reads master data for a single business partner.
  "! @raising zcx_merp_master_data | Raised if the requested business partner does not exist.
  METHODS read_partner
    IMPORTING iv_partner_code TYPE zmerp_r_bus_partner-PartnerCode
    RETURNING VALUE(rs_partner) TYPE ty_partner
    RAISING   zcx_merp_master_data.

  "! Reads master data for a list of business partners.
  METHODS read_partners
    IMPORTING it_partner_keys TYPE tt_partner_keys
    RETURNING VALUE(rt_partners) TYPE tt_partners.

  "! Validates business partner codes and returns missing/invalid keys.
  METHODS validate_partners
    IMPORTING it_partner_keys        TYPE tt_partner_keys
    RETURNING VALUE(rt_invalid_keys) TYPE tt_partner_keys.

ENDINTERFACE.
