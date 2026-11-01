@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stock Balance'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZMERP_I_STOCK_BALANCE
  as select from zmerp_stock_mov
{
  key company_code    as CompanyCode,
  key warehouse_code  as WarehouseCode,
  key item_code       as ItemCode,
  key unit_of_measure as UnitOfMeasure,
  key currency_code   as CurrencyCode,

      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
      sum( quantity ) as Quantity,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      sum( amount )   as StockValue
}
group by company_code,
         warehouse_code,
         item_code,
         unit_of_measure,
         currency_code
