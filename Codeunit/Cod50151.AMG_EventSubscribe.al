codeunit 50151 AMG_EventSubscribe
{
    // Mandatory check: Dimension selection needs to be mandatory
    [EventSubscriber(ObjectType::Page, Page::"Job Card", 'OnQueryClosePageEvent', '', false, false)]
    local procedure AMG_P88CheckDimension(var Rec: Record Job; var AllowClose: Boolean)
    var
        MiscMgmt: Codeunit AMG_MiscManagement;
    begin
        MiscMgmt.CheckDimensions(167, Rec."No.");
    end;

    // General Business Posting Group Required
    [EventSubscriber(ObjectType::Table, 210, 'OnAfterSetUpNewLine', '', false, false)]
    local procedure AMG_T210FlowGenBusPostingGroup(var JobJournalLine: Record "Job Journal Line"; LastJobJournalLine: Record "Job Journal Line"; JobJournalTemplate: Record "Job Journal Template"; JobJournalBatch: Record "Job Journal Batch")
    begin
        JobJournalLine."Gen. Bus. Posting Group" := JobJournalBatch.AMG_GenBusPostingGroup;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Job Journal", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure AMGP201_FlowGenBusPostingGroup(var Rec: Record "Job Journal Line")
    var
        JobJnlBatch: Record "Job Journal Batch";
    begin
        If JobJnlBatch.GET(rec."Journal Template Name", rec."Journal Batch Name") then begin
            rec."Gen. Bus. Posting Group" := JobJnlBatch.AMG_GenBusPostingGroup;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 81, 'OnAfterSetupNewLine', '', false, false)]
    local procedure AMG_T81FlowGenBusPostingGroup(var GenJournalLine: Record "Gen. Journal Line"; GenJournalTemplate: Record "Gen. Journal Template"; GenJournalBatch: Record "Gen. Journal Batch"; LastGenJournalLine: Record "Gen. Journal Line"; Balance: Decimal; BottomLine: Boolean)
    begin
        GenJournalLine."Gen. Bus. Posting Group" := GenJournalBatch.AMG_GenBusPostingGroup;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Job G/L Journal", 'OnAfterValidateEvent', 'Account No.', false, false)]
    local procedure AMG_P2010FlowGenBusPostingGroup(var Rec: Record "Gen. Journal Line")
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        If GenJournalBatch.get(rec."Journal Template Name", rec."Journal Batch Name") then begin
            rec."Gen. Bus. Posting Group" := GenJournalBatch.AMG_GenBusPostingGroup;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Job G/L Journal", 'OnAfterValidateEvent', 'Bal. Account No.', false, false)]
    local procedure AMG_P2010FlowGenBusPostingGroup2(var Rec: Record "Gen. Journal Line")
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        If GenJournalBatch.get(rec."Journal Template Name", rec."Journal Batch Name") then begin
            rec."Gen. Bus. Posting Group" := GenJournalBatch.AMG_GenBusPostingGroup;
        end;
    end;

    // Restriction needs to be imposed for not allowing to issue more quantity than budgeted & value.
    // Linked Job Ledger Entries with job Planning Line
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Transfer Line", 'OnAfterFromJnlLineToLedgEntry', '', false, false)]
    local procedure AMG_C1004JobValidation(VAR JobLedgerEntry: Record "Job Ledger Entry"; JobJournalLine: Record "Job Journal Line")
    var
    begin
        JobLedgerEntry.AMG_JobPlanningLineNo := JobJournalLine."Job Planning Line No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Jnl.-Check Line", 'OnBeforeRunCheck', '', false, false)]
    local procedure AMG_C1011JobValidation(var JobJnlLine: Record "Job Journal Line")
    var
        MiscMgmt: Codeunit AMG_MiscManagement;
    begin
        MiscMgmt.JobPostingValidationCode(JobJnlLine);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Job G/L Journal", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyJobGLJournal(var Rec: Record "Gen. Journal Line")
    var
        MiscMgmt: Codeunit AMG_MiscManagement;
    begin
        MiscMgmt.JobGLPostingValidationCode(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Job G/L Journal", 'OnAfterValidateEvent', 'Amount', false, false)]
    local procedure OnValidateAmoutJobGLJournal(var Rec: Record "Gen. Journal Line")
    var
        MiscMgmt: Codeunit AMG_MiscManagement;
    begin
        MiscMgmt.JobGLPostingValidationCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 81, 'OnBeforeValidateEvent', 'Job No.', false, false)]
    local procedure AMGT81FJobNoOnBeforeValidate(VAR Rec: Record "Gen. Journal Line"; VAR xRec: Record "Gen. Journal Line"; CurrFieldNo: Integer)
    begin
        IF (CurrFieldNo <> Rec.FIELDNO("Job No.")) And (Rec."Job Planning Line No." > 0) Then begin
            IF Rec."Job No." = '' Then
                Rec."Job No." := xRec."Job No.";
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Job Journal", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyJobJournal(var Rec: Record "Job Journal Line")
    var
        MiscMgmt: Codeunit AMG_MiscManagement;
    begin
        MiscMgmt.JobPostingValidationCode(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Job Journal", 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure OnValidateQuantityJobJournal(var Rec: Record "Job Journal Line")
    var
        MiscMgmt: Codeunit AMG_MiscManagement;
    begin
        MiscMgmt.JobPostingValidationCode(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Job Journal", 'OnAfterValidateEvent', 'Total Cost (LCY)', false, false)]
    local procedure OnValidateTotalCostLCYJobJournal(var Rec: Record "Job Journal Line")
    var
        MiscMgmt: Codeunit AMG_MiscManagement;
    begin
        MiscMgmt.JobPostingValidationCode(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Job Journal", 'OnAfterValidateEvent', 'Total Cost', false, false)]
    local procedure OnValidateTotalCostJobJournal(var Rec: Record "Job Journal Line")
    var
        MiscMgmt: Codeunit AMG_MiscManagement;
    begin
        MiscMgmt.JobPostingValidationCode(Rec);
    end;

    // [EventSubscriber(ObjectType::Table, 210, 'OnBeforeValidateEvent', 'Job No.', false, false)]
    // local procedure AMGT210FJobNoOnBeforeValidate(VAR Rec: Record "Job Journal Line"; VAR xRec: Record "Job Journal Line"; CurrFieldNo: Integer)
    // begin
    //     IF (CurrFieldNo <> Rec.FIELDNO("Job No.")) And (Rec."Job Planning Line No." > 0) Then begin
    //         IF Rec."Job No." = '' Then
    //             Rec."Job No." := xRec."Job No.";
    //     end;
    // end;

    //Budget Restriction required in PO & PI for items & G/L 
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure AMG_C90PostPurchaseValidation(VAR PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean)
    var
        MiscMgmt: Codeunit AMG_MiscManagement;
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.Reset();
        PurchLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
        IF PurchLine.FindSet() Then begin
            repeat
                MiscMgmt.CheckPointJobPurchLinePosting(PurchLine);
                MiscMgmt.JobPurchLinePostingValidation(PurchLine);
            Until PurchLine.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeValidateEvent', 'Quantity', false, false)]
    local procedure PurchaseLineQtyOnBeforeValidate(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        MiscMgmt: Codeunit AMG_MiscManagement;
    begin
        IF (Rec.Quantity <> xRec.Quantity) And (CurrFieldNo = Rec.FieldNo(Quantity)) And (Rec.Quantity > 0) Then
            MiscMgmt.CheckPointJobPurchLinePosting(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'Quantity', false, false)]
    local procedure PurchaseLineQtyAfterValidate(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        MiscMgmt: Codeunit AMG_MiscManagement;
    begin
        IF (Rec.Quantity <> xRec.Quantity) And (CurrFieldNo = Rec.FieldNo(Quantity)) And (Rec.Quantity > 0) Then
            MiscMgmt.CheckPointJobPurchLinePosting(Rec);
        IF (CurrFieldNo = Rec.FieldNo(Quantity)) And (Rec.Quantity > 0) Then
            MiscMgmt.JobPurchLinePostingValidation(Rec);
    end;

    // Auto creation of G/L account across the entities upon creating new G/L in any entity.
    [EventSubscriber(ObjectType::Table, 15, 'OnAfterInsertEvent', '', false, false)]
    procedure AMGT15_SynchronizeGLAccount(var Rec: Record "G/L Account"; RunTrigger: Boolean)
    var
        GLAccount: Record "G/L Account";
        CompanyRec: Record "Company";
        CompanyNameText: Text;
        CurrGLAccount: Record "G/L Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup.AMG_SynchronizeGLAccount then
            exit;
        CompanyRec.FINDSET();
        CurrGLAccount.Get(Rec."No.");
        REPEAT
            Commit();
            CompanyNameText := CompanyName;
            IF CompanyRec.Name <> CompanyNameText THEN BEGIN
                GLAccount.CHANGECOMPANY(CompanyRec.Name);
                IF Not GLAccount.Get(CurrGLAccount."No.") Then Begin
                    GLAccount.INIT();
                    GLAccount."No." := CurrGLAccount."No.";
                    GLAccount.INSERT(False);
                End;
            END;
        UNTIL CompanyRec.NEXT = 0;
    end;

    [EventSubscriber(ObjectType::Page, 17, 'OnModifyRecordEvent', '', false, false)]
    procedure AMG_P17SynchronizeGLAccount(var Rec: Record "G/L Account"; var xRec: Record "G/L Account"; var AllowModify: Boolean)
    var
        GLAccount: Record "G/L Account";
        CompanyRec: Record "Company";
        CurrCompanyNameText: Text;
        NewCompanyNameText: Text;
        CurrGLAccount: Record "G/L Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
        AMG_MiscManagement: Codeunit AMG_MiscManagement;
    begin
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup.AMG_SynchronizeGLAccount then
            exit;
        CompanyRec.FINDSET();
        REPEAT
            COMMIT();
            CLEAR(GLAccount);
            CurrCompanyNameText := CompanyName;
            NewCompanyNameText := CompanyRec.Name;
            IF CompanyRec.Name <> CurrCompanyNameText THEN BEGIN
                GLAccount.CHANGECOMPANY(NewCompanyNameText);
                GLAccount.LockTable();
                IF (GLAccount.GET(Rec."No.")) Then Begin
                    AMG_MiscManagement.CopyGLAccount(GLAccount, Rec);
                    GLAccount.MODIFY(False);
                    Commit();
                End Else Begin
                    GLAccount.Init();
                    GLAccount.LockTable();
                    GLAccount.CHANGECOMPANY(NewCompanyNameText);
                    GLAccount.TRANSFERFIELDS(Rec);
                    GLAccount.Insert(False);
                End;
            END;
        UNTIL CompanyRec.NEXT = 0;
    END;
}