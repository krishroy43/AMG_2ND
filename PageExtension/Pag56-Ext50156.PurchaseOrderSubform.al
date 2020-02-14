pageextension 50156 pageextension50156 extends "Purchase Order Subform"
{
    layout
    {
        addlast(Control1)
        {
            field(AMG_ShortClosed; AMG_ShortClosed)
            {
                Visible = ShortCloseVisible;
                ApplicationArea = All;
                ToolTip = 'Specifies the order is short closed.';
            }
            field(AMG_ShortClosedQty; AMG_ShortClosedQty)
            {
                Visible = ShortCloseVisible;
                ApplicationArea = All;
                ToolTip = 'Specifies the quantity is short closed quantity.';
            }
            field(AMG_Cancelled; AMG_Cancelled)
            {
                Visible = ShortCloseVisible;
                ApplicationArea = All;
                ToolTip = 'Specifies the order is cancelled.';
            }
            field(AMG_CancelledQty; AMG_CancelledQty)
            {
                Visible = ShortCloseVisible;
                ApplicationArea = All;
                ToolTip = 'Specifies the quantity is Cancelled quantity.';
            }
            // field(AMG_AppliedForClose; AMG_AppliedForClose)
            // {
            //     Visible = false;
            //     ApplicationArea = All;
            //     ToolTip = 'Specifies the order is applied for short close.';
            // }

            field(AMG_InitSourceNo; AMG_InitSourceNo)
            {
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Specifies the purchase requisition number.';
            }
            field(AMG_InitSourceLineNo; AMG_InitSourceLineNo)
            {
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Specifies the purchase requisition line number.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShortCloseVisible := AMG_ShortClosed or AMG_Cancelled;
    end;

    var
        ShortCloseVisible: Boolean;
}