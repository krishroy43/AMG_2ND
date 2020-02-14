xmlport 50153 "Export Layout Csv"
{
    Caption = 'Export Layout Csv';

    Direction = Export;
    Format = VariableText;
    UseRequestPage = false;
    FieldDelimiter = '';
    FieldSeparator = ',';
    RecordSeparator = 'New Line';

    schema
    {
        textelement(Root)
        {
            textelement(CAP_PrNo)
            {
                trigger OnBeforePassVariable()
                begin
                    CAP_PrNo := 'PR No.';
                end;
            }
            textelement(CAP_vesselNo)
            {
                trigger OnBeforePassVariable()
                begin
                    CAP_vesselNo := 'Vessel No.';
                end;
            }
            textelement(CAP_Segment)
            {
                trigger OnBeforePassVariable()
                begin
                    CAP_Segment := 'Segments';
                end;
            }
            textelement(Cap_Type)
            {
                trigger OnBeforePassVariable()
                begin
                    Cap_Type := 'Type';
                end;
            }
            textelement(Cap_IMPA)
            {
                trigger OnBeforePassVariable()
                begin
                    Cap_IMPA := 'IMPA';
                end;
            }
            textelement(Cap_Quantity)
            {
                trigger OnBeforePassVariable()
                begin
                    Cap_Quantity := 'Quantity';
                end;
            }
            textelement(Cap_UMO)
            {
                trigger OnBeforePassVariable()
                begin
                    Cap_UMO := 'UOM';
                end;
            }
            textelement(Cap_ROB)
            {
                trigger OnBeforePassVariable()
                begin
                    Cap_ROB := 'ROB';
                end;
            }
            textelement(Cap_Remarks)
            {
                trigger OnBeforePassVariable()
                begin
                    Cap_Remarks := 'Remarks';
                end;
            }
            textelement(Cap_locs)
            {
                trigger OnBeforePassVariable()
                begin
                    Cap_locs := 'Location Code';
                end;
            }
        }

    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPostXmlPort()
    begin
        RecDialog.CLOSE;
    end;

    trigger OnPreXmlPort()
    begin
        FirstLine := TRUE;
        RecDialog.OPEN('@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\')
    end;

    var
        FirstLine: Boolean;
        RecDialog: Dialog;
        RecCOunt: Integer;
        index: Integer;
        PurchAndPayableSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        HeaderRec: Record AMG_PurchRequisitionHeader;
        LineRec: Record AMG_PurchRequisitionLine;
        DocNo: Code[20];
        V_VessalNo: Code[20];
        LineNo: Integer;
        V_IMPA: Code[20];
        V_Qty: Decimal;
        V_UOm: Code[20];
        V_ROB: Decimal;

    procedure InsertHeaderDetails(VesselNo_P: Text[50])
    begin
        PurchAndPayableSetup.Get();
        HeaderRec.Init();
        DocNo := NoSeriesMgt.GetNextNo(PurchAndPayableSetup.AMG_PurchReqNos, Today, true);
        Message(DocNo);
        HeaderRec.Validate("No.", DocNo);
        HeaderRec.Validate("Shortcut Dimension 1 Code", VesselNo_P);
        HeaderRec.Validate("Shortcut Dimension 2 Code", 'SRM');
        HeaderRec.Insert();
    end;

    procedure InsertLineDetails(Type_p: Text[20]; IMPA_P: Text[20]; Qty_P: Text[20]; Uom_P: Text[20]; ROB_P: Text[20]; Remarks_p: Text[250])
    begin
        LineRec.Init();
        LineRec.Validate("Document No.", DocNo);
        LineRec."Line No." := LineNo;
        Evaluate(LineRec.Type, Type_p);
        Evaluate(V_IMPA, IMPA_P);
        LineRec.Validate("No.", V_IMPA);
        Evaluate(V_Qty, Qty_P);
        LineRec.Validate(Quantity, V_Qty);
        Evaluate(v_UOM, Uom_P);
        LineRec.Validate("Unit of Measure Code", V_UOm);
        Evaluate(V_ROB, ROB_P);
        LineRec.Validate(ROB, V_ROB);
        Evaluate(LineRec.Remarks, Remarks_p);
        LineRec.Insert();
    end;
}

