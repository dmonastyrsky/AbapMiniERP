@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'VAT Rate Usage Dependencies'
@VDM.viewType: #COMPOSITE
define view entity ZMERP_I_VAT_RATE_USAGE
  as select from ZMERP_R_ITEM_GROUP
{
  key DefaultVatCode as VatCode,
      'Item Group'    as UsedInEntity
}
