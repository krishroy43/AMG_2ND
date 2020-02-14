tableextension 50151 tableextension50151 extends "Purchases & Payables Setup"
{
    fields
    {
        field(50151; AMG_PurchReqNos; Code[20])
        {
            Caption = 'Purchase Requisition No.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

}