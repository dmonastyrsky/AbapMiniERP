@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Usage Dependencies'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZMERP_I_PURCHASEORDER_USAGE
  as select from ZMERP_R_GOODSRECEIPT
{
  key PoReferenceUUID                                  as DocumentUUID,
  key cast( bintohex( DocumentUUID ) as abap.char(40) ) as RefEntityKey,
  key cast( 'Goods Receipt' as zmerp_entity_name )     as UsedInEntity
}
where PoReferenceUUID is not initial

union all select from ZMERP_R_GOODSRECEIPTITM
{
  key PoItemReferenceUUID                              as DocumentUUID,
  key cast( bintohex( ItemUUID ) as abap.char(40) )     as RefEntityKey,
  key cast( 'Goods Receipt Item' as zmerp_entity_name ) as UsedInEntity
}
where PoItemReferenceUUID is not initial
