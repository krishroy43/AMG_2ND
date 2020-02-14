table 50152 AMG_PurchRequisitionLine
{
    DataClassification = CustomerContent;
    Caption = 'Purch. Requisition Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,G/L Account,Item,,Fixed Asset';
            OptionMembers = " ","G/L Account",Item,,"Fixed Asset";
            DataClassification = CustomerContent;
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(" ")) "Standard Text"
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account" WHERE("Direct Posting" = CONST(true), "Account Type" = CONST(Posting), Blocked = CONST(false))
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"
            ELSE
            IF (Type = CONST(Item)) Item WHERE(Blocked = CONST(false), "Purchasing Blocked" = CONST(false))
            ELSE
            IF (Type = CONST(Item)) Item WHERE(Blocked = CONST(false))
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemRec: Record Item;
                GLAccount: Record "G/L Account";
                FixedAsset: Record "Fixed Asset";
                HeaderRec: Record AMG_PurchRequisitionHeader;
            begin
                GetPurchReqHeader(HeaderRec);
                Validate("Dimension Set ID", HeaderRec."Dimension Set ID");

                case Type of
                    Type::Item:
                        if ItemRec.Get("No.") then begin
                            Description := ItemRec.Description;
                            "Unit of Measure Code" := ItemRec."Purch. Unit of Measure";
                        end;
                    Type::"G/L Account":
                        if GLAccount.Get("No.") then begin
                            Description := GLAccount.Name;
                        end;
                    Type::"Fixed Asset":
                        if FixedAsset.Get("No.") then begin
                            Description := FixedAsset.Description;
                        end;
                end;
            end;
        }
        field(7; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            TableRelation = IF (Type = CONST("G/L Account")) "G/L Account".Name WHERE("Direct Posting" = CONST(true), "Account Type" = CONST(Posting), Blocked = CONST(false))
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account".Name
            ELSE
            IF (Type = CONST(Item)) Item.Description WHERE(Blocked = CONST(false), "Purchasing Blocked" = CONST(false))
            ELSE
            IF (Type = CONST(Item)) Item.Description WHERE(Blocked = CONST(false));
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        //<LT_30Dec19>
        field(16; ROB; Decimal) { }
        field(17; Remarks; Text[250]) { }
        //</LT_30Dec19>
        field(40; "Shortcut Dimension 1 Code"; Code[20])
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
        field(41; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2),
                                                          Blocked = CONST(false));
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(42; "Shortcut Dimension 3 Code"; Code[20])
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
        field(43; "Shortcut Dimension 4 Code"; Code[20])
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
        field(44; "Shortcut Dimension 5 Code"; Code[20])
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
        field(45; "Shortcut Dimension 6 Code"; Code[20])
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
        field(46; "Shortcut Dimension 7 Code"; Code[20])
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
        field(47; "Shortcut Dimension 8 Code"; Code[20])
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
        field(51; OrderCreated; Boolean)
        {
            Caption = 'Order Created';
            FieldClass = FlowField;
            CalcFormula = exist ("Purchase Line" where("Document Type" = filter(Order), AMG_InitSourceNo = field("Document No."), AMG_InitSourceLineNo = field("Line No.")));
            Editable = false;
        }
        field(52; QuoteCreated; Boolean)
        {
            Caption = 'Quote Created';
            FieldClass = FlowField;
            CalcFormula = exist ("Purchase Line" where("Document Type" = filter(Quote), AMG_InitSourceNo = field("Document No."), AMG_InitSourceLineNo = field("Line No.")));
            Editable = false;
        }
        field(68; Inventory; Decimal)
        {
            CalcFormula = Sum ("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("No."), "Location Code" = FIELD("Location Code")));
            Caption = 'Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = CustomerContent;
            trigger OnLookup()
            begin
                ShowDimensions;
            end;

            trigger OnValidate()
            begin
                UpdateGlobalDimFromDimSetID("Dimension Set ID", Rec);
            end;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF (Type = CONST(Item), "Document No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("No."))
            ELSE
            "Unit of Measure";
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin

        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");

    end;

    procedure ShowDimensions() IsChanged: Boolean
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', "Document No.", "Line No."));
        // VerifyItemLineDim;
        UpdateGlobalDimFromDimSetID("Dimension Set ID", Rec);
        IsChanged := OldDimSetID <> "Dimension Set ID";

    end;

    procedure UpdateGlobalDimFromDimSetID(DimSetID: Integer; var ParRec: Record AMG_PurchRequisitionLine)
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

    local procedure GetPurchReqHeader(var ParPurchReqHeader: Record AMG_PurchRequisitionHeader)
    begin
        //ParPurchReqHeader.Get(Rec."Document No.");
    end;

}