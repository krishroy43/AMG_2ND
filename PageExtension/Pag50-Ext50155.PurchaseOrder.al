pageextension 50155 pageextension50155 extends "Purchase Order"
{
    layout
    {
        addlast(General)
        {
            field(AMG_ShortClosed; AMG_ShortClosed)
            {
                Visible = ShortCloseVisible;
                ApplicationArea = All;
                ToolTip = 'Specifies the order is short closed.';
            }
            field(AMG_Cancelled; AMG_Cancelled)
            {
                Visible = ShortCloseVisible;
                ApplicationArea = All;
                ToolTip = 'Specifies the order is cancelled.';
            }
            field(AMG_InitSourceNo; AMG_InitSourceNo)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the purchase requisition number.';
            }
        }
    }
    actions
    {
        addlast("F&unctions")
        {
            action("Short Close")
            {
                Visible = Not ShortCloseVisible;
                ApplicationArea = All;
                Image = Close;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = '';
                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                    PurchaseLine: Record "Purchase Line";
                    ReleasePurchDOc: Codeunit "Release Purchase Document";
                    TotalLine: Integer;
                    StatusReleased: Boolean;
                    WantToShortcloseConfirm: Label 'Do you really want to short close the purchase order?';
                    TextshortCloseMsg: Label 'Order is successfully short closed.';
                    TextcancelCloseMsg: Label 'Order is successfully canceled.';
                    NothingToShortCloseError: Label 'There is nothing to short close.';
                    QuantityReceived: Decimal;
                    TotalQuantity: Decimal;
                begin
                    IF NOT CONFIRM(WantToShortcloseConfirm, FALSE) THEN
                        EXIT;

                    CheckforPendingInvoice;

                    IF Status = Status::Released THEN BEGIN
                        PerformManualReopen(Rec);
                        StatusReleased := TRUE;
                    END;

                    Clear(QuantityReceived);
                    TotalQuantity := 0;
                    TotalLine := 0;
                    PurchaseLine.RESET;
                    PurchaseLine.SETRANGE("Document Type", "Document Type");
                    PurchaseLine.SETRANGE("Document No.", "No.");
                    IF PurchaseLine.FINDSET THEN BEGIN
                        TotalLine := PurchaseLine.COUNT;
                        IF TotalLine = 0 then
                            Error(NothingToShortCloseError);
                        REPEAT
                            TotalQuantity += PurchaseLine.Quantity;
                            QuantityReceived += PurchaseLine."Quantity Received";
                        UNTIL PurchaseLine.NEXT = 0;
                    END;

                    IF TotalQuantity = 0 Then
                        Error(NothingToShortCloseError);

                    IF QuantityReceived > 0 Then begin
                        UpdateLineShortClose(Rec, True, false);
                        IF StatusReleased THEN Begin
                            ReleasePurchDOc.PerformManualRelease(Rec);
                            Rec.UpdateWhseRqst(Rec, true);
                        End;
                    end else begin
                        UpdateLineShortClose(Rec, false, True);
                    end;

                    IF QuantityReceived > 0 Then begin
                        MESSAGE(TextshortCloseMsg);
                    end else begin
                        MESSAGE(TextcancelCloseMsg);
                    end;
                    CurrPage.Close();
                end;
            }
            action("Undo Short Close")
            {
                Visible = ShortCloseVisible;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Undo Short Close';
                Image = Undo;

                trigger OnAction()
                var
                    ReleasePurchDOc: Codeunit "Release Purchase Document";
                    WantToUndoShortcloseConfirm: Label 'Do you really want to undo short close the purchase order?';
                    TextUndoshortCloseMsg: Label 'Order is successfully undo.';
                begin
                    IF NOT CONFIRM(WantToUndoShortcloseConfirm, FALSE) THEN
                        EXIT;

                    UndoShortClosePurchase(Rec);

                    MESSAGE(TextUndoshortCloseMsg);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        ShortCloseVisible := AMG_ShortClosedorCancelled;
    end;

    trigger OnOpenPage()
    begin
        ShortCloseVisible := AMG_ShortClosedorCancelled;
    end;

    Var
        [InDataSet]
        ShortCloseVisible: Boolean;
}