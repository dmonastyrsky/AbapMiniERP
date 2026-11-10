@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Usage Dependencies'
@Metadata.ignorePropagatedAnnotations: true

// Goods issues referencing a sales order will be added here (goods issue pass)
define view entity ZMERP_I_SO_USAGE
  as select from ZMERP_R_SALESORDER
{
  key DocumentUUID                                 as DocumentUUID,
  key cast( '' as abap.char(40) )                  as RefEntityKey,
  key cast( 'Goods Issue' as zmerp_entity_name )   as UsedInEntity
}
where 1 = 0 // Dummy implementation until goods issues exist
