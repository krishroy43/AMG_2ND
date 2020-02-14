table 50151 AMG_PurchRequisitionHeader
{
    DataClassification = CustomerContent;
    Caption = 'Purch. Requisition Header';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Coordinator Name"; Text[50])
        {
            Caption = 'Coordinator Name';
            DataClassification = CustomerContent;
        }
        field(12; "Requisition Date"; Date)
        {
            Caption = 'Requisition Date';
            DataClassification = CustomerContent;
        }
        field(29; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1),
                                                          Blocked = CONST(false));
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(30; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(31; "Shortcut Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                          Blocked = CONST(false));
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(3, "Shortcut Dimension 3 Code");
            end;
        }
        field(32; "Shortcut Dimension 4 Code"; Code[20])
        {
            CaptionClass = '1,2,4';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                          Blocked = CONST(false));
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(4, "Shortcut Dimension 4 Code");
            end;
        }
        field(33; "Shortcut Dimension 5 Code"; Code[20])
        {
            CaptionClass = '1,2,5';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                          Blocked = CONST(false));
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(5, "Shortcut Dimension 5 Code");
            end;
        }
        field(34; "Shortcut Dimension 6 Code"; Code[20])
        {
            CaptionClass = '1,2,6';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                          Blocked = CONST(false));
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(6, "Shortcut Dimension 6 Code");
            end;
        }
        field(35; "Shortcut Dimension 7 Code"; Code[20])
        {
            CaptionClass = '1,2,7';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                          Blocked = CONST(false));
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(7, "Shortcut Dimension 7 Code");
            end;
        }
        field(36; "Shortcut Dimension 8 Code"; Code[20])
        {
            CaptionClass = '1,2,8';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                          Blocked = CONST(false));
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(8, "Shortcut Dimension 8 Code");
            end;
        }
        field(51; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            Editable = false;
        }
        field(52; "OrderCreated"; Boolean)
        {
            Caption = 'Order Created';
            FieldClass = FlowField;
            CalcFormula = exist ("Purchase Header" where("Document Type" = const(Order), AMG_InitSourceNo = field("No.")));
            Editable = false;
        }
        field(60; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = ToBeClassified;
        }

        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                ShowDocDim;
            end;

            trigger OnValidate()
            begin
                UpdateGlobalDimFromDimSetID("Dimension Set ID", Rec);
            end;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        PurchAndPayableSetup: Record "Purchases & Payables Setup";
        DimMgt: Codeunit DimensionManagement;
        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnDelete()
    var
        PurchReqLine: Record AMG_PurchRequisitionLine;
    begin
        PurchReqLine.RESET;
        PurchReqLine.SETRANGE("Document No.", "No.");
        IF PurchReqLine.FINDSET THEN Begin
            PurchReqLine.DeleteAll();
        end;
    end;

    trigger OnInsert()
    begin
        PurchAndPayableSetup.GET;
        IF "No." = '' THEN BEGIN
            PurchAndPayableSetup.TESTFIELD(AMG_PurchReqNos);
            NoSeriesMgt.InitSeries(PurchAndPayableSetup.AMG_PurchReqNos, xRec."No. Series", TODAY, "No.", "No. Series");
            "Created By" := UserId;
        END;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    var
        OldDimSetID: Integer;
    begin

        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if "No." <> '' then
            Modify;

        if OldDimSetID <> "Dimension Set ID" then begin
            Modify;
            if PurchRequisitionLineExist then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;

    end;

    procedure ShowDocDim()
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet(
            "Dimension Set ID", StrSubstNo('%1', "No."));

        if OldDimSetID <> "Dimension Set ID" then begin
            UpdateGlobalDimFromDimSetID("Dimension Set ID", Rec);
            Modify;
            if PurchRequisitionLineExist then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure PurchRequisitionLineExist(): Boolean
    Var
        PurchReqLine: Record AMG_PurchRequisitionLine;
    begin
        PurchReqLine.Reset;
        PurchReqLine.SetRange("Document No.", "No.");
        exit(not PurchReqLine.IsEmpty);
    end;

    procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer)
    var
        PurchReqLine: Record AMG_PurchRequisitionLine;
        ConfirmManagement: Codeunit "Confirm Management";
        NewDimSetID: Integer;
        ReceivedShippedItemLineDimChangeConfirmed: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit;

        if NewParentDimSetID = OldParentDimSetID then
            exit;
        // if not GetHideValidationDialog then
        //     if not ConfirmManagement.GetResponseOrDefault(Text051, true) then
        //         exit;

        PurchReqLine.Reset;
        PurchReqLine.SetRange("Document No.", "No.");
        PurchReqLine.LockTable;
        if PurchReqLine.Find('-') then
            repeat
                NewDimSetID := DimMgt.GetDeltaDimSetID(PurchReqLine."Dimension Set ID", NewParentDimSetID, OldParentDimSetID);
                if PurchReqLine."Dimension Set ID" <> NewDimSetID then begin
                    PurchReqLine."Dimension Set ID" := NewDimSetID;

                    // if not GetHideValidationDialog and GuiAllowed then
                    //     VerifyReceivedShippedItemLineDimChange(ReceivedShippedItemLineDimChangeConfirmed);

                    PurchReqLine.UpdateGlobalDimFromDimSetID(PurchReqLine."Dimension Set ID", PurchReqLine);

                    PurchReqLine.Modify;
                end;
            until PurchReqLine.Next = 0;
    end;

    procedure UpdateGlobalDimFromDimSetID(DimSetID: Integer; var ParRec: Record AMG_PurchRequisitionHeader)
    var
        ShortcutDimCode: array[8] of Code[20];
        GetShortcutDimensionValues: Codeunit "Get Shortcut Dimension Values";
    begin
        GetShortcutDimensionValues.GetShortcutDimensions(DimSetID, ShortcutDimCode);
        ParRec."Shortcut Dimension 1 Code" := ShortcutDimCode[1];
        ParRec."Shortcut Dimension 2 Code" := ShortcutDimCode[2];
        ParRec."Shortcut Dimension 3 Code" := ShortcutDimCode[3];
        ParRec."Shortcut Dimension 4 Code" := ShortcutDimCode[4];
        ParRec."Shortcut Dimension 5 Code" := ShortcutDimCode[5];
        ParRec."Shortcut Dimension 6 Code" := ShortcutDimCode[6];
        ParRec."Shortcut Dimension 7 Code" := ShortcutDimCode[7];
        ParRec."Shortcut Dimension 8 Code" := ShortcutDimCode[8];
    end;

    procedure CheckMandatoryFields(var ParHeader: Record AMG_PurchRequisitionHeader; var ParLine: Record AMG_PurchRequisitionLine)
    var
        GLSetup: Record "General Ledger Setup";
        Text001: Label 'Purchase requisition line is not found.';
    begin
        GLSetup.Get;

        ParHeader.TestField("Requisition Date");
        ParHeader.TestField("Shortcut Dimension 1 Code");
        ParHeader.TestField("Shortcut Dimension 2 Code");
        ParHeader.TestField("Shortcut Dimension 3 Code");
        // ParHeader.TestField("Coordinator Name");
        // if GLSetup."Shortcut Dimension 4 Code" <> '' then
        //     ParHeader.TestField("Shortcut Dimension 4 Code");
        // if GLSetup."Shortcut Dimension 5 Code" <> '' then
        //     ParHeader.TestField("Shortcut Dimension 5 Code");
        // if GLSetup."Shortcut Dimension 6 Code" <> '' then
        //     ParHeader.TestField("Shortcut Dimension 6 Code");
        // if GLSetup."Shortcut Dimension 7 Code" <> '' then
        //     ParHeader.TestField("Shortcut Dimension 7 Code");
        // if GLSetup."Shortcut Dimension 8 Code" <> '' then
        //     ParHeader.TestField("Shortcut Dimension 8 Code");

        if ParLine.FindSet() then
            repeat
                if ParLine.Type <> ParLine.Type::" " then begin
                    ParLine.TestField(Type);
                    ParLine.TestField("No.");
                    ParLine.TestField(Description);
                    ParLine.TestField(Quantity);
                    if ParLine.Type = ParLine.Type::Item then begin
                        ParLine.TestField("Unit of Measure Code");
                        ParLine.TestField("Location Code");
                    end;
                    ParLine.TestField("Shortcut Dimension 1 Code");
                    ParLine.TestField("Shortcut Dimension 2 Code");
                    ParLine.TestField("Shortcut Dimension 3 Code");
                end else begin
                    ParLine.TestField(Description);
                end;
            // if GLSetup."Shortcut Dimension 4 Code" <> '' then
            //     ParLine.TestField("Shortcut Dimension 4 Code");
            // if GLSetup."Shortcut Dimension 5 Code" <> '' then
            //     ParLine.TestField("Shortcut Dimension 5 Code");
            // if GLSetup."Shortcut Dimension 6 Code" <> '' then
            //     ParLine.TestField("Shortcut Dimension 6 Code");
            // if GLSetup."Shortcut Dimension 7 Code" <> '' then
            //     ParLine.TestField("Shortcut Dimension 7 Code");
            // if GLSetup."Shortcut Dimension 8 Code" <> '' then
            //     ParLine.TestField("Shortcut Dimension 8 Code");
            until ParLine.Next() = 0
        else
            Error(Text001);
    end;
}