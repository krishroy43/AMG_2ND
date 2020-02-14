pageextension 50157 pageextension50157 extends "Purchase Quote"
{
    layout
    {
        addlast(General)
        {
            field(AMG_InitSourceNo; AMG_InitSourceNo)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the purchase requisition number.';
            }
        }
    }

}