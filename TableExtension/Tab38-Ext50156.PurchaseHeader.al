tableextension 50156 tableextension50156 extends "Purchase Header"
{
    fields
    {
        // Purchase Requisition. //
        field(50151; AMG_InitSourceNo; Code[20])
        {
            Caption = 'Purchase Requisition No.';
            DataClassification = CustomerContent;
            Editable = false;
        }

        // Option to Short Close and cancelation of Purchase order. 
        //In case of Vendor refuse to deliver the goods partially or completely.
        field(50152; AMG_ShortClosed; Boolean)
        {
            Caption = 'Short Closed';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50153; AMG_Cancelled; Boolean)
        {
            Caption = 'Cancelled';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50154; AMG_ShortClosedOrCancelled; Boolean)
        {
            Caption = 'Short Closed Or Cancelled Order';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    procedure UpdateLineShortClose(Var ParRec: Record "Purchase Header"; ParShortClose: Boolean; ParCancel: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
        PLineOld: Record "Purchase Line";
    begin

        ParRec.AMG_ShortClosed := ParShortClose;
        ParRec.AMG_Cancelled := ParCancel;
        ParRec.AMG_ShortClosedOrCancelled := ParShortClose OR ParCancel;
        ParRec.MODIFY(false);

        PLineOld.RESET;
        PLineOld.SETRANGE("Document No.", "No.");
        PLineOld.SETRANGE("Document Type", "Document Type");
        //PurchaseLine.SETRANGE(AMG_AppliedForClose, TRUE);
        IF PLineOld.FindSet() THEN Begin
            Repeat
                PurchaseLine.Get(PLineOld."Document Type", PLineOld."Document No.", PLineOld."Line No.");
                PurchaseLine.AMG_OriginalQty := PurchaseLine.Quantity;
                IF PurchaseLine."Quantity Received" > 0 THEN begin
                    PurchaseLine.VALIDATE(AMG_ShortClosedQty, PurchaseLine.Quantity - PurchaseLine."Quantity Received");
                    IF PurchaseLine.Type = PurchaseLine.Type::Item Then
                        PurchaseLine.VALIDATE(Quantity, PurchaseLine."Quantity Received");
                    PurchaseLine."AMG_ShortClosed" := TRUE;
                end Else begin
                    PurchaseLine.VALIDATE(AMG_CancelledQty, PurchaseLine.Quantity);
                    IF PurchaseLine.Type = PurchaseLine.Type::Item Then
                        PurchaseLine.VALIDATE(Quantity, 0);
                    PurchaseLine.AMG_Cancelled := TRUE;
                end;
                IF PurchaseLine.Type = PurchaseLine.Type::Item Then
                    PurchaseLine.VALIDATE("Outstanding Qty. (Base)", 0);
                PurchaseLine.MODIFY;
            until PLineOld.Next() = 0;
        End;
    end;

    procedure UndoShortClosePurchase(var ParRec: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        PLine: Record "Purchase Line";
    begin
        PLine.RESET;
        PLine.SETRANGE("Document Type", "Document Type");
        PLine.SETRANGE("Document No.", "No.");
        IF PLine.FINDSET THEN BEGIN
            REPEAT
                PurchaseLine.Get(PLine."Document Type", PLine."Document No.", PLine."Line No.");
                PurchaseLine.VALIDATE(Quantity, PurchaseLine.AMG_OriginalQty);
                PurchaseLine.VALIDATE(AMG_OriginalQty, 0);
                PurchaseLine.VALIDATE(AMG_CancelledQty, 0);
                PurchaseLine.VALIDATE(AMG_ShortClosedQty, 0);
                PurchaseLine.AMG_Cancelled := false;
                PurchaseLine.AMG_ShortClosed := false;
                PurchaseLine.MODIFY;
            UNTIL PLine.NEXT = 0;
        END;
        ParRec.AMG_ShortClosed := false;
        ParRec.AMG_Cancelled := false;
        ParRec.AMG_ShortClosedOrCancelled := False;
        ParRec.Modify();
    end;

    procedure CheckforPendingInvoice()
    var
        TempInt: Integer;
        Text5000: Label 'Invoice must be posted before short close.';
        PurchaseLine: Record "Purchase Line";
    begin
        TempInt := 0;
        PurchaseLine.RESET;
        PurchaseLine.SETCURRENTKEY("Document No.", "Document Type");
        PurchaseLine.SETRANGE("Document No.", "No.");
        PurchaseLine.SETRANGE("Document Type", "Document Type");
        PurchaseLine.SETRANGE(AMG_AppliedForClose, TRUE);
        IF PurchaseLine.FINDSET THEN
            REPEAT
                IF (PurchaseLine."Qty. Received (Base)" <> PurchaseLine."Qty. Invoiced (Base)") THEN
                    TempInt += 1;
            UNTIL PurchaseLine.NEXT = 0;
        IF TempInt <> 0 THEN
            ERROR(Text5000)
    end;


    procedure PerformManualReopen(Var PurchHeader: Record "Purchase Header")
    var
        Text00001: Label 'The approval process must be canceled or completed to reopen this document.';
    begin
        IF PurchHeader.Status = PurchHeader.Status::"Pending Approval" THEN
            ERROR(Text00001);

        UpdateWhseRqst(PurchHeader, False);
    end;

    procedure UpdateWhseRqst(var PurchHeader: Record "Purchase Header"; ParReleased: Boolean)
    var
        WhseRqst: Record "Warehouse Request";
        WhsePurchRelease: Codeunit "Whse.-Purch. Release";
    begin
        WhsePurchRelease.Reopen(PurchHeader);
        WhseRqst.RESET;
        WhseRqst.SETCURRENTKEY("Source Type", "Source Subtype", "Source No.");
        WhseRqst.SETRANGE(Type, WhseRqst.Type::Inbound);
        WhseRqst.SETRANGE("Source Type", DATABASE::"Purchase Line");
        WhseRqst.SETRANGE("Source Subtype", "Document Type");
        WhseRqst.SETRANGE("Source No.", "No.");
        WhseRqst.SETRANGE("Document Status", PurchHeader.Status::Released);
        IF WhseRqst.FIND('-') THEN
            REPEAT
                IF ParReleased Then
                    WhseRqst."Document Status" := PurchHeader.Status::Released
                else
                    WhseRqst."Document Status" := PurchHeader.Status::Open;
                WhseRqst.MODIFY;
            UNTIL WhseRqst.NEXT = 0;

        PurchHeader.Status := PurchHeader.Status::Open;
        PurchHeader.MODIFY(TRUE);
    end;

}