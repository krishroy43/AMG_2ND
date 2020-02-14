pageextension 50159 pageextension50159 extends "Purchase Order List"
{
    trigger OnOpenPage()
    begin
        FilterGroup(2);
        SetRange(AMG_ShortClosedOrCancelled, false);
    end;
}