@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item: Posted Goods Receipt Totals'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZMERP_I_PO_ITEM_GR_TOTALS
  as select from ZMERP_R_GOODSRECEIPTITM as gri
    inner join   ZMERP_R_GOODSRECEIPT    as grh on grh.DocumentUUID = gri.HeaderUUID
{
  key gri.PoItemReferenceUUID as PoItemUUID,
  key gri.UnitOfMeasure       as UnitOfMeasure,
  key gri.CurrencyCode        as CurrencyCode,

      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
      sum( gri.Quantity )     as ReceivedQuantity,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      sum( gri.NetAmount )    as ReceivedNetAmount,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      sum( gri.VatAmount )    as ReceivedVatAmount,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      sum( gri.GrossAmount )  as ReceivedGrossAmount,

      count( * )              as ReceiptItemCount
}
where grh.Status = 'P'
  and gri.PoItemReferenceUUID is not initial
group by gri.PoItemReferenceUUID,
         gri.UnitOfMeasure,
         gri.CurrencyCode
