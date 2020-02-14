pageextension 50152 pageextension50152 extends "Job Journal Batches"
{
    layout
    {
        addlast(Control1)
        {
            field(AMG_GenBusPostingGroup; AMG_GenBusPostingGroup)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
            }
        }
    }

}