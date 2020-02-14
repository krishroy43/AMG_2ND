codeunit 50152 AMG_MiscManagement
{
    // JOBS: Mandatory check: Dimension selection needs to be mandatory //
    procedure CheckDimensions(ParTableId: Integer; ParNo: Code[20])
    var
        DimSetEntry: Record "Dimension Set Entry";
        GLSetup: Record "General Ledger Setup";
        DefaultDimension: Record "Default Dimension";
    begin
        GLSetup.Get();
        GLSetup.TestField("Global Dimension 1 Code");
        GLSetup.TestField("Shortcut Dimension 3 Code");
        DefaultDimension.Reset();
        IF Not (DefaultDimension.GET(ParTableId, ParNo, GLSetup."Global Dimension 1 Code")) Then
            DefaultDimension.GET(ParTableId, ParNo, GLSetup."Global Dimension 1 Code")
        else
            DefaultDimension.TestField("Dimension Value Code");
        IF Not (DefaultDimension.GET(ParTableId, ParNo, GLSetup."Shortcut Dimension 3 Code")) Then
            DefaultDimension.GET(ParTableId, ParNo, GLSetup."Shortcut Dimension 3 Code")
        else Begin
            IF Not (DefaultDimension."Value Posting" in [DefaultDimension."Value Posting"::"Code Mandatory", DefaultDimension."Value Posting"::"Same Code"]) Then
                DefaultDimension.FieldError("Value Posting", 'Code Mandatory or same code');
        end
    end;

    // Purchase Requisition. //
    procedure CreatePurchDocument(Var ParPurchReqHeader: Record AMG_PurchRequisitionHeader; Var ParPurchReqLine: Record AMG_PurchRequisitionLine; Var ParPurchType: Option Quote,"Order")
    var
        VendorRec: Record Vendor;
        PurchaseHeaderRec: Record "Purchase Header";
        PurchaseLineRec: Record "Purchase Line";
        VendorList: Page "Vendor Lookup";
        Text50151: Label 'Purchase Quote %1 is created.';
        Text50152: Label 'Purchase Order %1 is created.';
    begin
        VendorRec.Reset();
        VendorRec.SetCurrentKey("No.", Blocked);
        VendorRec.SetRange(Blocked, VendorRec.Blocked::" ");
        if VendorRec.FindSet() then begin
            VendorList.SetRecord(VendorRec);
            VendorList.LookupMode(true);
            if Not (VendorList.RunModal() = Action::LookupOK) then
                exit;
            VendorList.GetRecord(VendorRec);
        end;

        PurchaseHeaderRec.Init();
        case ParPurchType of
            ParPurchType::Quote:
                begin
                    // Do not allow to create quote for same vendor & same line.
                    CheckOrderCreated(ParPurchReqLine);
                    PurchaseHeaderRec."Document Type" := PurchaseHeaderRec."Document Type"::Quote;
                    CheckQuoteExistForVendor(ParPurchReqLine, VendorRec);

                end;
            ParPurchType::Order:
                begin
                    // Even if one quote is generated from PR then do not allow to create order for same lines
                    PurchaseHeaderRec."Document Type" := PurchaseHeaderRec."Document Type"::Order;
                    CheckOrderCreated(ParPurchReqLine);
                    CheckQuateCreated(ParPurchReqLine);
                end;
        end;

        PurchaseHeaderRec."No." := '';
        PurchaseHeaderRec.Insert(true);

        PurchaseHeaderRec.Validate("Buy-from Vendor No.", VendorRec."No.");
        PurchaseHeaderRec.Validate("Document Date", Today);
        PurchaseHeaderRec.Validate("Dimension Set ID", ParPurchReqHeader."Dimension Set ID");
        PurchaseHeaderRec.AMG_InitSourceNo := ParPurchReqHeader."No.";
        PurchaseHeaderRec.Modify(true);

        If ParPurchReqLine.FindFirst() then
            repeat
                PurchaseLineRec.Init();
                PurchaseLineRec."Document Type" := PurchaseHeaderRec."Document Type";
                PurchaseLineRec."Document No." := PurchaseHeaderRec."No.";
                PurchaseLineRec."Line No." := GetLastLineNo(PurchaseHeaderRec);
                PurchaseLineRec.Insert(true);

                PurchaseLineRec.Validate(Type, ParPurchReqLine.Type);
                PurchaseLineRec.Validate("No.", ParPurchReqLine."No.");
                PurchaseLineRec.Description := ParPurchReqLine.Description;
                PurchaseLineRec.Validate("Location Code", ParPurchReqLine."Location Code");
                PurchaseLineRec.Validate(Quantity, ParPurchReqLine.Quantity);
                PurchaseLineRec.Validate("Unit of Measure Code", ParPurchReqLine."Unit of Measure Code");
                PurchaseLineRec.Validate("Dimension Set ID", ParPurchReqLine."Dimension Set ID");
                PurchaseLineRec.AMG_InitSourceNo := ParPurchReqLine."Document No.";
                PurchaseLineRec.AMG_InitSourceLineNo := ParPurchReqLine."Line No.";
                PurchaseLineRec.Modify(true);
            until ParPurchReqLine.Next() = 0;

        case PurchaseHeaderRec."Document Type" of
            PurchaseHeaderRec."Document Type"::Quote:
                Message(Text50151, PurchaseHeaderRec."No.");
            PurchaseHeaderRec."Document Type"::Order:
                Message(Text50152, PurchaseHeaderRec."No.");
        end;
    end;

    local procedure GetLastLineNo(ParPurchaseHeader: Record "Purchase Header"): Integer
    var
        PurchaseLineRec: Record "Purchase Line";
    begin
        PurchaseLineRec.Reset();
        PurchaseLineRec.SetCurrentKey("Document Type", "Document No.");
        PurchaseLineRec.SetRange("Document Type", ParPurchaseHeader."Document Type");
        PurchaseLineRec.SetRange("Document No.", ParPurchaseHeader."No.");
        if PurchaseLineRec.FindLast() then
            exit(PurchaseLineRec."Line No." + 10000)
        else
            exit(10000)
    end;

    procedure CheckOrderCreated(Var ParReqLine: Record AMG_PurchRequisitionLine)
    begin
        if ParReqLine.FindSet() then
            repeat
                ParReqLine.CalcFields(OrderCreated);
                if ParReqLine.OrderCreated then
                    ParReqLine.FieldError(OrderCreated);
            until ParReqLine.Next() = 0;
    end;

    procedure CheckQuateCreated(Var ParReqLine: Record AMG_PurchRequisitionLine)
    begin
        if ParReqLine.FindSet() then
            repeat
                ParReqLine.CalcFields(QuoteCreated);
                if ParReqLine.QuoteCreated then
                    ParReqLine.FieldError(QuoteCreated);
            until ParReqLine.Next() = 0;
    end;

    procedure CheckQuoteExistForVendor(Var ParReqLine: Record AMG_PurchRequisitionLine; var ParVendRec: Record Vendor)
    var
        PurchLine: Record "Purchase Line";
        ErrorQuoteAlreadyExist: Label 'Purchase quote: %1 already exist for the vendor %2. where Requisition line type: %3, No.:%4, ';
    begin
        if ParReqLine.FindSet() then
            repeat
                ParReqLine.CalcFields(QuoteCreated);
                if ParReqLine.QuoteCreated then begin
                    PurchLine.Reset();
                    PurchLine.SetCurrentKey("Document Type", "No.", "Line No.", "Buy-from Vendor No.", AMG_InitSourceNo, AMG_InitSourceLineNo);
                    PurchLine.SetRange("Document Type", PurchLine."Document Type"::Quote);
                    PurchLine.SetRange("Buy-from Vendor No.", ParVendRec."No.");
                    PurchLine.SetRange(AMG_InitSourceNo, ParReqLine."Document No.");
                    PurchLine.SetRange(AMG_InitSourceLineNo, ParReqLine."Line No.");
                    if PurchLine.FindFirst() then
                        Error(ErrorQuoteAlreadyExist, ParReqLine."Document No.", ParVendRec."No.", Format(ParReqLine.Type), ParReqLine."No.");
                end;
            until ParReqLine.Next() = 0;
    end;

    // Restriction needs to be imposed for not allowing to issue more quantity than budgeted & value.
    procedure JobPostingValidationCode(VAR ParRec: Record "Job Journal Line")
    var
        JobPlanningLine: Record "Job Planning Line";
        JobSetup: Record "Jobs Setup";
        JobLedgerEntries: Record "Job Ledger Entry";
        BugetLimitErrorTxt: Text;
        BudgetQuantity: Decimal;
        PostedQuantity: Decimal;
        PostedTotalCost: Decimal;
        RemQty: Decimal;
        BudgetTotalCost: Decimal;
        RemTotalCost: Decimal;
        BudgetTotalAmount: Decimal;
        RemTotalAmount: Decimal;
        ErrorNoRemainingUsage: Label 'There is no remaining usage on the job(s)';

    begin
        Clear(BugetLimitErrorTxt);
        Clear(BudgetQuantity);
        Clear(PostedQuantity);
        Clear(PostedTotalCost);
        Clear(RemQty);
        Clear(BudgetTotalAmount);
        Clear(RemTotalAmount);
        Clear(BudgetTotalCost);
        Clear(RemTotalCost);
        JobSetup.Get();
        IF (JobSetup.AMG_NotAllowExceedBudget) And (ParRec."Job Planning Line No." > 0) And
        ((ParRec."Job No." <> '') AND (ParRec."Job Task No." <> '')) Then Begin
            JobPlanningLine.Reset;
            JobPlanningLine.SetCurrentKey("Job No.", "Job Task No.", "Line No.", Type, "No.");
            JobPlanningLine.SetRange("Job No.", ParRec."Job No.");
            JobPlanningLine.SetRange("Job Task No.", ParRec."Job Task No.");
            IF ParRec."Job Planning Line No." > 0 Then
                JobPlanningLine.SetRange("Line No.", ParRec."Job Planning Line No.");
            IF ParRec.Type = ParRec.Type::"G/L Account" Then
                JobPlanningLine.SetRange(Type, JobPlanningLine.Type::"G/L Account");
            IF ParRec.Type = ParRec.Type::Item Then
                JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
            IF ParRec.Type = ParRec.Type::Resource Then
                JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Resource);

            JobPlanningLine.SetRange("No.", ParRec."No.");
            IF JobPlanningLine.FindSet() then Begin
                JobPlanningLine.CalcSums(Quantity, "Remaining Qty.", "Total Cost (LCY)", "Remaining Total Cost (LCY)", "Line Amount (LCY)", "Remaining Line Amount (LCY)");
                BudgetQuantity := JobPlanningLine.Quantity;
                BudgetTotalCost := JobPlanningLine."Total Cost (LCY)";
                BudgetTotalAmount := JobPlanningLine."Line Amount (LCY)";
                JobLedgerEntries.Reset;
                JobLedgerEntries.SetCurrentKey("Job No.", "Job Task No.", Type, "No.", AMG_JobPlanningLineNo, "Entry No.");
                JobLedgerEntries.SetRange("Job No.", ParRec."Job No.");
                JobLedgerEntries.SetRange("Job Task No.", ParRec."Job Task No.");
                IF ParRec.Type = ParRec.Type::"G/L Account" Then
                    JobPlanningLine.SetRange(Type, JobLedgerEntries.Type::"G/L Account");
                IF ParRec.Type = ParRec.Type::Item Then
                    JobPlanningLine.SetRange(Type, JobLedgerEntries.Type::Item);
                IF ParRec.Type = ParRec.Type::Resource Then
                    JobPlanningLine.SetRange(Type, JobLedgerEntries.Type::Resource);
                JobLedgerEntries.SetRange("No.", ParRec."No.");
                IF ParRec."Job Planning Line No." > 0 Then
                    JobLedgerEntries.SetRange(AMG_JobPlanningLineNo, ParRec."Job Planning Line No.");
                IF JobLedgerEntries.FindSet() then
                    repeat
                        PostedQuantity += JobLedgerEntries.Quantity;
                        PostedTotalCost += JobLedgerEntries."Total Cost (LCY)";
                    //JobLedgerEntries."Line Amount (LCY)");
                    until JobLedgerEntries.Next() = 0;

                RemQty := BudgetQuantity - PostedQuantity;
                RemTotalCost := BudgetTotalCost - PostedTotalCost;
                //RemTotalAmount := BudgetTotalAmount - JobLedgerEntries."Line Amount (LCY)";
                IF RemQty < 0 then
                    RemQty := 0;
                IF RemTotalCost < 0 then
                    RemTotalCost := 0;
                IF RemTotalAmount < 0 then
                    RemTotalAmount := 0;
            end Else
                JobPlanningLine.Get(ParRec."Job No.", ParRec."Job Task No.", ParRec."Job Planning Line No.");

            IF (RemQty < ParRec.Quantity) then Begin //AND (Not (ParRec.Type = ParRec.Type::"G/L Account")) THEN Begin
                IF RemQty = 0 then
                    Error(ErrorNoRemainingUsage);
                BugetLimitErrorTxt := StrSubstNo('must not be greater than remaining budget: %1', FORMAT(RemQty));
                ParRec.FIELDERROR(Quantity, BugetLimitErrorTxt);
            End;

            // IF (RemTotalAmount < ParRec."Line Amount (LCY)") AND (ParRec.Type = ParRec.Type::"G/L Account") THEN begin
            //     IF RemTotalAmount = 0 then
            //         Error(ErrorNoRemainingUsage);
            //     BugetLimitErrorTxt := StrSubstNo('must not be greater than remaining budget: %1', FORMAT(RemTotalAmount));
            //     ParRec.FIELDERROR("Line Amount (LCY)", BugetLimitErrorTxt);
            // End;

            IF RemTotalCost < ParRec."Total Cost (LCY)" THEN begin
                IF RemTotalCost = 0 then
                    Error(ErrorNoRemainingUsage);
                BugetLimitErrorTxt := StrSubstNo('must not be greater than remaining budget: %1', FORMAT(RemTotalCost));
                ParRec.FIELDERROR("Total Cost (LCY)", BugetLimitErrorTxt);
            End;
        end;
    end;

    procedure JobGLPostingValidationCode(VAR ParRec: Record "Gen. Journal Line")
    var
        JobPlanningLine: Record "Job Planning Line";
        JobSetup: Record "Jobs Setup";
        JobLedgerEntries: Record "Job Ledger Entry";
        BugetLimitErrorTxt: Text;
        BudgetQuantity: Decimal;
        PostedQuantity: Decimal;
        postedTotalCost: Decimal;
        RemQty: Decimal;
        BudgetTotalCost: Decimal;
        //BudgetTotalAmount: Decimal;
        RemTotalCost: Decimal;
        //RemTotalAmount: Decimal;
        ErrorNoRemainingUsage: Label 'There is no remaining usage on the job(s)';
    begin
        Clear(BugetLimitErrorTxt);
        Clear(BudgetQuantity);
        Clear(PostedQuantity);
        Clear(postedTotalCost);
        Clear(RemQty);
        Clear(BudgetTotalCost);
        //Clear(BudgetTotalAmount);
        Clear(RemTotalCost);
        //Clear(RemTotalAmount);
        JobSetup.Get();
        IF (JobSetup.AMG_NotAllowExceedBudget) And (ParRec."Job Planning Line No." > 0) And
        ((ParRec."Job No." <> '') AND (ParRec."Job Task No." <> '')) Then Begin
            IF ParRec."Account Type" = ParRec."Account Type"::"G/L Account" Then begin
                JobPlanningLine.Reset;
                JobPlanningLine.SetCurrentKey("Job No.", "Job Task No.", "Line No.", Type, "No.");
                JobPlanningLine.SetRange("Job No.", ParRec."Job No.");
                JobPlanningLine.SetRange("Job Task No.", ParRec."Job Task No.");
                IF ParRec."Job Planning Line No." > 0 Then
                    JobPlanningLine.SetRange("Line No.", ParRec."Job Planning Line No.");
                JobPlanningLine.SetRange(Type, JobPlanningLine.Type::"G/L Account");
                JobPlanningLine.SetRange("No.", ParRec."Account No.");

                IF JobPlanningLine.FindSet() then Begin
                    JobPlanningLine.CalcSums(Quantity, "Total Cost (LCY)", "Line Amount (LCY)");
                    BudgetQuantity := JobPlanningLine.Quantity;
                    BudgetTotalCost := JobPlanningLine."Total Cost (LCY)";
                    //BudgetTotalAmount := JobPlanningLine."Line Amount (LCY)";

                    JobLedgerEntries.Reset;
                    JobLedgerEntries.SetCurrentKey("Job No.", "Job Task No.", Type, "No.", AMG_JobPlanningLineNo, "Entry No.");
                    JobLedgerEntries.SetRange("Job No.", ParRec."Job No.");
                    JobLedgerEntries.SetRange("Job Task No.", ParRec."Job Task No.");
                    JobLedgerEntries.SetRange(Type, JobLedgerEntries.Type::"G/L Account");
                    JobLedgerEntries.SetRange("No.", ParRec."Account No.");
                    IF ParRec."Job Planning Line No." > 0 Then
                        JobLedgerEntries.SetRange(AMG_JobPlanningLineNo, ParRec."Job Planning Line No.");
                    IF JobLedgerEntries.FindSet() then
                        repeat
                            PostedQuantity += JobLedgerEntries.Quantity;
                            postedTotalCost += JobLedgerEntries."Total Cost (LCY)";
                        //JobLedgerEntries."Line Amount (LCY)");
                        until JobLedgerEntries.Next() = 0;
                    RemQty := BudgetQuantity - PostedQuantity;
                    RemTotalCost := BudgetTotalCost - postedTotalCost;
                    //RemTotalAmount := BudgetTotalAmount - JobLedgerEntries."Line Amount (LCY)";
                    IF RemQty < 0 then
                        RemQty := 0;
                    IF RemTotalCost < 0 then
                        RemTotalCost := 0;
                    //IF RemTotalAmount < 0 then
                    //    RemTotalAmount := 0;

                    //IF (RemQty < ParRec."Job Quantity") then begin //AND (Not (ParRec.Type = ParRec.Type::"G/L Account")) THEN Begin
                    //    IF RemQty = 0 then
                    //        Error(ErrorNoRemainingUsage);
                    //    BugetLimitErrorTxt := StrSubstNo('must not be grater than remaining budget: %1', FORMAT(RemQty));
                    //    ParRec.FIELDERROR(Quantity, BugetLimitErrorTxt);
                    //End;

                    IF RemTotalCost < ParRec."Amount (LCY)" THEN begin
                        IF RemTotalCost = 0 then
                            Error(ErrorNoRemainingUsage);
                        BugetLimitErrorTxt := StrSubstNo('must not be greater than remaining budget: %1', FORMAT(RemTotalCost));
                        ParRec.FIELDERROR("Amount (LCY)", BugetLimitErrorTxt);
                    End;

                    // IF RemTotalAmount < ParRec."Amount (LCY)" THEN begin
                    //     IF RemTotalAmount = 0 then
                    //         Error(ErrorNoRemainingUsage);
                    //     BugetLimitErrorTxt := StrSubstNo('must not be greater than remaining budget: %1', FORMAT(RemTotalAmount));
                    //     ParRec.FIELDERROR("Amount (LCY)", BugetLimitErrorTxt);
                    // End;
                end Else
                    JobPlanningLine.Get(ParRec."Job No.", ParRec."Job Task No.", ParRec."Job Planning Line No.");

            End;
        end;
    end;

    //Budget Restriction required in PO & PI for items & G/L
    procedure CheckPointJobPurchLinePosting(VAR ParRec: Record "Purchase Line")
    var
        myInt: Integer;
    begin
        IF (ParRec.Type IN [ParRec.Type::Item, ParRec.Type::"G/L Account"]) And (ParRec."No." <> '') Then Begin
            ParRec.TestField("Job No.");
            ParRec.TestField("Job Task No.");
            ParRec.TestField("Job Planning Line No.");
            //ParRec.TestField();
        End;
    end;

    procedure JobPurchLinePostingValidation(VAR ParRec: Record "Purchase Line")
    var
        JobPlanningLine: Record "Job Planning Line";
        JobSetup: Record "Jobs Setup";
        JobLedgerEntries: Record "Job Ledger Entry";
        BugetLimitErrorTxt: Text;
        BudgetQuantity: Decimal;
        PostedQuantity: Decimal;
        postedTotalCost: Decimal;
        RemQty: Decimal;
        BudgetTotalCost: Decimal;
        RemTotalCost: Decimal;
        ErrorNoRemainingUsage: Label 'There is no remaining usage on the job(s)';
    begin
        Clear(BugetLimitErrorTxt);
        Clear(BudgetQuantity);
        Clear(PostedQuantity);
        Clear(postedTotalCost);
        Clear(RemQty);
        Clear(BudgetTotalCost);
        Clear(RemTotalCost);
        JobSetup.Get();
        IF (JobSetup.AMG_NotAllowExceedBudget) And (ParRec."Job Planning Line No." > 0) And
        ((ParRec."Job No." <> '') AND (ParRec."Job Task No." <> '')) Then Begin
            IF ParRec.Type in [ParRec.Type::"G/L Account", ParRec.Type::Item] Then begin
                JobPlanningLine.Reset;
                JobPlanningLine.SetCurrentKey("Job No.", "Job Task No.", "Line No.", Type, "No.");
                JobPlanningLine.SetRange("Job No.", ParRec."Job No.");
                JobPlanningLine.SetRange("Job Task No.", ParRec."Job Task No.");
                IF ParRec."Job Planning Line No." > 0 Then
                    JobPlanningLine.SetRange("Line No.", ParRec."Job Planning Line No.");
                IF ParRec.Type = ParRec.Type::"G/L Account" Then
                    JobPlanningLine.SetRange(Type, JobPlanningLine.Type::"G/L Account");
                IF ParRec.Type = ParRec.Type::Item Then
                    JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
                JobPlanningLine.SetRange("No.", ParRec."No.");

                IF JobPlanningLine.FindSet() then Begin
                    JobPlanningLine.CalcSums(Quantity, "Total Cost (LCY)", "Line Amount (LCY)");
                    BudgetQuantity := JobPlanningLine.Quantity;
                    BudgetTotalCost := JobPlanningLine."Total Cost (LCY)";

                    JobLedgerEntries.Reset;
                    JobLedgerEntries.SetCurrentKey("Job No.", "Job Task No.", Type, "No.", AMG_JobPlanningLineNo, "Entry No.");
                    JobLedgerEntries.SetRange("Job No.", ParRec."Job No.");
                    JobLedgerEntries.SetRange("Job Task No.", ParRec."Job Task No.");
                    IF ParRec.Type = ParRec.Type::"G/L Account" Then
                        JobLedgerEntries.SetRange(Type, JobLedgerEntries.Type::"G/L Account");
                    IF ParRec.Type = ParRec.Type::Item Then
                        JobLedgerEntries.SetRange(Type, JobLedgerEntries.Type::item);
                    JobLedgerEntries.SetRange("No.", ParRec."No.");
                    IF ParRec."Job Planning Line No." > 0 Then
                        JobLedgerEntries.SetRange(AMG_JobPlanningLineNo, ParRec."Job Planning Line No.");
                    IF JobLedgerEntries.FindSet() then
                        repeat
                            PostedQuantity += JobLedgerEntries.Quantity;
                            postedTotalCost += JobLedgerEntries."Total Cost (LCY)";
                        until JobLedgerEntries.Next() = 0;
                    RemQty := BudgetQuantity - PostedQuantity;
                    RemTotalCost := BudgetTotalCost - postedTotalCost;

                    IF RemQty < 0 then
                        RemQty := 0;
                    IF RemTotalCost < 0 then
                        RemTotalCost := 0;

                    IF (RemQty < ParRec.Quantity) AND (Not (ParRec.Type = ParRec.Type::"G/L Account")) THEN Begin
                        IF RemQty = 0 then
                            Error(ErrorNoRemainingUsage);
                        BugetLimitErrorTxt := StrSubstNo('must not be grater than remaining budget: %1', FORMAT(RemQty));
                        ParRec.FIELDERROR(Quantity, BugetLimitErrorTxt);
                    End;

                    IF RemTotalCost < ParRec."Line Amount" THEN begin
                        IF RemTotalCost = 0 then
                            Error(ErrorNoRemainingUsage);
                        BugetLimitErrorTxt := StrSubstNo('must not be greater than remaining budget: %1', FORMAT(RemTotalCost));
                        ParRec.FIELDERROR("Line Amount", BugetLimitErrorTxt);
                    end;

                end Else
                    JobPlanningLine.Get(ParRec."Job No.", ParRec."Job Task No.", ParRec."Job Planning Line No.");

            End;
        end;
    end;

    // Auto creation of G/L account across the entities upon creating new G/L in any entity.
    procedure CopyGLAccount(var ParGLAccount: Record "G/L Account"; ParRec: Record "G/L Account")
    var
    begin
        ParGLAccount."Name" := ParRec."Name";
        ParGLAccount."Search Name" := ParRec."Search Name";
        ParGLAccount."Account Type" := ParRec."Account Type";
        ParGLAccount."Global Dimension 1 Code" := ParRec."Global Dimension 1 Code";
        ParGLAccount."Global Dimension 2 Code" := ParRec."Global Dimension 2 Code";
        ParGLAccount."Account Category" := ParRec."Account Category";
        ParGLAccount."Income/Balance" := ParRec."Income/Balance";
        ParGLAccount."Debit/Credit" := ParRec."Debit/Credit";
        ParGLAccount."No. 2" := ParRec."No. 2";
        ParGLAccount."Comment" := ParRec."Comment";
        ParGLAccount."Blocked" := ParRec."Blocked";
        ParGLAccount."Direct Posting" := ParRec."Direct Posting";
        ParGLAccount."Reconciliation Account" := ParRec."Reconciliation Account";
        ParGLAccount."New Page" := ParRec."New Page";
        ParGLAccount."No. of Blank Lines" := ParRec."No. of Blank Lines";
        ParGLAccount."Indentation" := ParRec."Indentation";
        ParGLAccount."Last Modified Date Time" := ParRec."Last Modified Date Time";
        ParGLAccount."Last Date Modified" := ParRec."Last Date Modified";
        ParGLAccount."Totaling" := ParRec."Totaling";
        ParGLAccount."Consol. Translation Method" := ParRec."Consol. Translation Method";
        ParGLAccount."Consol. Debit Acc." := ParRec."Consol. Debit Acc.";
        ParGLAccount."Consol. Credit Acc." := ParRec."Consol. Credit Acc.";
        ParGLAccount."Gen. Posting Type" := ParRec."Gen. Posting Type";
        ParGLAccount."Gen. Bus. Posting Group" := ParRec."Gen. Bus. Posting Group";
        ParGLAccount."Gen. Prod. Posting Group" := ParRec."Gen. Prod. Posting Group";
        ParGLAccount."Picture" := ParRec."Picture";
        ParGLAccount."Automatic Ext. Texts" := ParRec."Automatic Ext. Texts";
        ParGLAccount."Tax Area Code" := ParRec."Tax Area Code";
        ParGLAccount."Tax Liable" := ParRec."Tax Liable";
        ParGLAccount."Tax Group Code" := ParRec."Tax Group Code";
        ParGLAccount."VAT Bus. Posting Group" := ParRec."VAT Bus. Posting Group";
        ParGLAccount."VAT Prod. Posting Group" := ParRec."VAT Prod. Posting Group";
        ParGLAccount."Exchange Rate Adjustment" := ParRec."Exchange Rate Adjustment";
        ParGLAccount."Default IC Partner G/L Acc. No" := ParRec."Default IC Partner G/L Acc. No";
        ParGLAccount."Omit Default Descr. in Jnl." := ParRec."Omit Default Descr. in Jnl.";
        ParGLAccount."Account Subcategory Entry No." := ParRec."Account Subcategory Entry No.";
        ParGLAccount."Cost Type No." := ParRec."Cost Type No.";
        ParGLAccount."Default Deferral Template Code" := ParRec."Default Deferral Template Code";
        ParGLAccount."Id" := ParRec."Id";
        // ParGLAccount."GIFI Code" := ParRec."GIFI Code";
        // ParGLAccount."SAT Account Code" := ParRec."SAT Account Code";
    end;
}