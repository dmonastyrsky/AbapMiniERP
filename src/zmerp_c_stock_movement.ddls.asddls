@EndUserText.label: 'Stock Movement Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZMERP_C_STOCK_MOVEMENT
  provider contract transactional_query
  as projection on ZMERP_R_STOCK_MOVEMENT
{
  key MovementUUID,

      CompanyCode,
      WarehouseCode,
      ItemCode,

      PostingDate,
      Direction,

      DocumentType,
      DocumentUUID,
      DocumentNumber,

      Quantity,
      UnitOfMeasure,

      StockValue,
      CurrencyCode
}
