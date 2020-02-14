pageextension 50151 pageextension50151 extends "Purchases & Payables Setup"
{
    layout
    {
        addlast(content)
        {
            group("Misc Setup")
            {
                Caption = 'Misc Setup';
                field(AMG_PurchReqNos; AMG_PurchReqNos)
                {
                    Caption = 'Purchase Requisition Nos.';
                    ApplicationArea = All;
                    ToolTip = 'Specify the number series that will be used to assign numbers to purchase requisition.';
                }
            }
        }
    }
}