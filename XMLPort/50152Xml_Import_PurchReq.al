xmlport 50152 "Import CSV"
{
    Caption = 'Import CSV';

    Direction = Import;
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {

            tableelement(IntegerS; Integer)
            {
                AutoSave = false;
                MinOccurs = Zero;
                XmlName = 'UserRole';
                textelement(PrNo)
                {
                    trigger OnBeforePassVariable()
                    begin
                        If PrNo = Prno2 then
                            PrNo := '';
                    End;

                }
                textelement(VesselNo) { }
                textelement(Segment) { }
                textelement(Types) { }
                textelement(IMPA) { }
                textelement(Quantity) { }
                textelement(UOM) { }
                textelement(ROB) { }
                textelement(Remarks) { }
                textelement(Location) { }
                //textelement(Dates){}


                trigger OnBeforeInsertRecord()
                var

                    CommentLineNo: Integer;
                    LineNo: Integer;

                begin
                    // Start Skip First Line
                    IF FirstLine THEN BEGIN
                        FirstLine := FALSE;
                        currXMLport.SKIP;
                        CommentLineNo := 1000;
                    END;
                    // Stop Skip First Line

                    // Start Header Information Insert
                    IF (PrNo <> '') THEN BEGIN
                        If (PrNo <> Prno2) then begin
                            If VesselNo = '' then
                                VesselNo := VesselTemp;
                            //MESSAGE('this is Header')
                            //LineNo := 10000;
                            InsertHeaderDetails(PrNo, VesselNo, Segment);//,Dates);
                                                                         //InsertLineDetails(PrNo, Types, IMPA, Quantity, UOM, ROB, Remarks, LineNo);
                                                                         // Commit();//krishna
                        end;

                    END;
                    //MESSAGE('this is line %1', RecCOunt);
                    //LineNo += 10000;
                    LineNo += 10000;
                    InsertLineDetails(PrNo, VesselNo, Segment, Types, IMPA, Quantity, UOM, ROB, Remarks, LineNo);
                    //   Commit();//krishna

                    //END;
                    //VesselTemp := VesselNo;
                    Prno2 := PrNo;
                    // Stop Header Information Insert
                    // Start Progress Bar
                    SLEEP(100);
                    RecCOunt += 1;
                    IF RecCOunt <> 0 THEN
                        RecDialog.UPDATE(1, ROUND(10000 / RecCOunt * index, 1));
                    index += 1;
                    // Stop Progress Bar
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
        LineRec2: Record AMG_PurchRequisitionLine;
        DocNo: Code[20];
        V_VessalNo: Code[20];
        LineNo: Integer;
        V_IMPA: Code[20];
        V_Qty: Decimal;
        V_UOm: Code[20];
        V_ROB: Decimal;
        GlSetup: Record "General Ledger Setup";
        DimValRec: Record "Dimension Value";
        Date_V: Date;
        Prno2: text[20];
        VesselTemp: Text;

    procedure InsertHeaderDetails(PrNo_p: Text[50]; VesselNo_P: Text[50]; Segment_P: Text[50])//;Date_p:Text[10])
    begin
        GlSetup.Get();
        DimValRec.Reset();
        DimValRec.SetRange("Dimension Code", GlSetup."Global Dimension 2 Code");
        If DimValRec.FindFirst() then;
        PurchAndPayableSetup.Reset();
        PurchAndPayableSetup.Get();
        PurchAndPayableSetup.TestField(AMG_PurchReqNos);
        HeaderRec.Init();
        //DocNo := NoSeriesMgt.GetNextNo(PurchAndPayableSetup.AMG_PurchReqNos, Today, true);
        //HeaderRec."No." := DocNo;
        HeaderRec."No." := PrNo_p;
        HeaderRec.Insert();
        HeaderRec.Validate("Shortcut Dimension 1 Code", VesselNo_P);
        HeaderRec.Validate("Shortcut Dimension 2 Code", Segment_P);
        HeaderRec.Validate("Requisition Date", WorkDate());
        //Evaluate(Date_V,Date_V);
        HeaderRec.Modify();


    end;


    procedure InsertLineDetails(PrNo_p: Text[20]; VesselNo_P: Text[50]; Segment_P: Text[50]; Type_p: Text[20]; IMPA_P: Text[20]; Qty_P: Text[20]; Uom_P: Text[20]; ROB_P: Text[20]; Remarks_p: Text[250]; lineNo_P: Integer)
    begin
        LineRec2.Reset();
        LineRec2.SetRange("Document No.", DocNo);
        if LineRec2.FindLast() then;
        LineRec.Init();
        LineRec.Validate("Document No.", PrNo_p);
        LineRec."Line No." += 10000;
        LineRec.Validate("Shortcut Dimension 1 Code", VesselNo_P);
        LineRec.Validate("Shortcut Dimension 2 Code", Segment_P);
        if Location <> '' then
            LineRec.Validate("Location Code", Location);
        LineRec.Insert();
        /*If Type_P = '' then
            lineRec.Type := LineRec.Type::" "
        else*/
        Evaluate(LineRec.Type, Type_p);
        Evaluate(V_IMPA, IMPA_P);
        LineRec.Validate("No.", V_IMPA);
        Evaluate(V_Qty, Qty_P);
        LineRec.Validate(Quantity, V_Qty);
        Evaluate(v_UOM, Uom_P);
        LineRec.Validate("Unit of Measure Code", V_UOm);
        if ROB_P <> '' then begin
            Evaluate(V_ROB, ROB_P);
            LineRec.Validate(ROB, V_ROB);
        End;
        if Remarks_p <> '' then
            Evaluate(LineRec.Remarks, Remarks_p);
        LineRec.Validate("Shortcut Dimension 1 Code", VesselNo_P);
        LineRec.Validate("Shortcut Dimension 2 Code", Segment_P);
        /*if Loc_p <> '' then
            LineRec.Validate("Location Code", Location_P);*/
        LineRec.Modify();

    end;
}

