pageextension 50158 pageextension50158 extends "General Ledger Setup"
{

    layout
    {
        addlast(General)
        {
            field(AMG_SynchronizeGLAccount; AMG_SynchronizeGLAccount)
            {
                Caption = 'Synchronize G/L Account';
                ApplicationArea = All;
                ToolTip = 'Specifies if G/L accounts are automatically synchronize in all companies or not.';
            }
        }
    }
}
