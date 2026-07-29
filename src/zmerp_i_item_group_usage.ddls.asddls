@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Group Usage Dependencies'
@VDM.viewType: #COMPOSITE
@Metadata.ignorePropagatedAnnotations: true
define view entity ZMERP_I_ITEM_GROUP_USAGE
  as select from ZMERP_R_ITEM
{
  key ItemGroupCode,
      'Item' as UsedInEntity
}
where ItemGroupCode is not initial
