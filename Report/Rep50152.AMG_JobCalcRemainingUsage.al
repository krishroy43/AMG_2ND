report 50152 AMG_JobCalcRemainingUsage
{
    Caption = 'Job Calc. Remaining Usage';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Job Task"; "Job Task")
        {
            DataItemTableView = SORTING("Job No.", "Job Task No.");
            // RequestFilterFields = "Job No.", "Job Task No.";
            dataitem("Job Planning Line"; "Job Planning Line")
            {
                DataItemLink = "Job No." = FIELD("Job No."), "Job Task No." = FIELD("Job Task No.");
                DataItemTableView = SORTING("Job No.", "Job Task No.", "Line No.") where(Type = filter(Item | Resource | Text));
                RequestFilterFields = Type, "No.", "Planning Date", "Currency Date", "Location Code", "Variant Code", "Work Type Code";

                trigger OnPreDataItem()
                begin
                    "Job Planning Line".SetFilter("Job No.", JobNo);
                    "Job Planning Line".SetFilter("Job Task No.", JobTaskNo);
                end;

                trigger OnAfterGetRecord()
                begin
                    InitDiffBuffer;
                    if ("Job No." <> '') and ("Job Task No." <> '') then
                        CreateJT("Job Planning Line");
                    PostDiffBuffer(DocNo, PostingDate, TemplateName, BatchName);
                    Commit;
                end;
            }
            trigger OnPreDataItem()
            begin
                "Job Task".SetFilter("Job No.", JobNo);
                "Job Task".SetFilter("Job Task No.", JobTaskNo);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DocumentNo; DocNo)
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the number of a document that the calculation will apply to.';
                    }
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date for the document.';
                    }
                    field(TemplateName; TemplateName)
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Template Name';
                        Editable = false;
                        Lookup = false;
                        TableRelation = "Gen. Journal Template";
                        ToolTip = 'Specifies the template name of the job journal where the remaining usage is inserted as lines.';

                        trigger OnValidate()
                        begin
                            if TemplateName = '' then begin
                                BatchName := '';
                                exit;
                            end;
                            GenJnlTemplate.Get(TemplateName);
                            if GenJnlTemplate.Type <> GenJnlTemplate.Type::Jobs then begin
                                GenJnlTemplate.Type := GenJnlTemplate.Type::Jobs;
                                Error(Text001,
                                  GenJnlTemplate.TableCaption, GenJnlTemplate.FieldCaption(Type), GenJnlTemplate.Type);
                            end;
                        end;
                    }
                    field(BatchName; BatchName)
                    {
                        ApplicationArea = Jobs;
                        Caption = 'Batch Name';
                        Editable = false;
                        Lookup = false;
                        ToolTip = 'Specifies the name of the journal batch, a personalized journal layout, that the journal is based on.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if TemplateName = '' then
                                Error(Text000, JobJnlLine.FieldCaption("Journal Template Name"));
                            JobJnlLine."Journal Template Name" := TemplateName;
                            JobJnlLine.FilterGroup := 2;
                            JobJnlLine.SetRange("Journal Template Name", TemplateName);
                            JobJnlLine.SetRange("Journal Batch Name", BatchName);
                            JobJnlManagement.LookupName(BatchName, JobJnlLine);
                            JobJnlManagement.CheckName(BatchName, JobJnlLine);
                        end;

                        trigger OnValidate()
                        begin
                            JobJnlManagement.CheckName(BatchName, JobJnlLine);
                        end;
                    }
                }
                group(JobTask)
                {
                    Caption = 'Job Task';
                    field(JobNo; JobNo)
                    {
                        Caption = 'Job No.';
                        ApplicationArea = All;
                        NotBlank = true;
                        TableRelation = Job;
                        ShowMandatory = true;
                        trigger OnValidate()
                        begin
                            Clear(JobTaskNo);
                        end;
                    }
                    field(JobTaskNo; JobTaskNo)
                    {
                        Caption = 'Job Task No.';
                        ApplicationArea = All;
                        NotBlank = true;
                        ShowMandatory = true;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            JobTaskRec: Record "Job Task";
                            JobTaskList: Page "Job Task List";
                        begin
                            JobTaskRec.Reset();
                            JobTaskRec.SetRange("Job No.", JobNo);
                            if JobTaskRec.FindSet() then begin
                                JobTaskList.LookupMode(true);
                                JobTaskList.SetTableView(JobTaskRec);
                                if JobTaskList.RunModal() = Action::LookupOK then begin
                                    JobTaskList.GetRecord(JobTaskRec);
                                    JobTaskNo := JobTaskRec."Job Task No.";
                                end;
                            end;
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            TemplateName := TemplateName3;
            BatchName := BatchName3;
            DocNo := DocNo2;
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            myInt: Integer;
            JobTaskRec: Record "Job Task";
        begin
            if CloseAction = Action::OK then begin
                if JobNo = '' then
                    //Error('Job No. must be required');
                        JobTaskRec.FieldError("Job No.");
                if JobTaskNo = '' then
                    //Error('Job Task No. must be required.');
                    JobTaskRec.FieldError("Job Task No.");
            end;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        //PostDiffBuffer(DocNo, PostingDate, TemplateName, BatchName);
        IF CreatedGLLineCount = 0 THEN
            MESSAGE(Text50151)
        ELSE
            MESSAGE(Text50152, CreatedGLLineCount);
    end;

    trigger OnPreReport()
    begin
        Clear(CreatedGLLineCount);
        "Job Task".SetFilter("Job No.", JobNo);
        "Job Task".SetFilter("Job Task No.", JobTaskNo);
        JobCalcBatches.BatchError(PostingDate, DocNo);
        //InitDiffBuffer;
    end;

    var
        JobDiffBuffer: array[2] of Record "Job Difference Buffer" temporary;
        GenJnlTemplate: Record "Gen. Journal Template";
        JobJnlLine: Record "Job Journal Line";
        JobCalcBatches: Codeunit "Job Calculate Batches";
        JobJnlManagement: Codeunit JobJnlManagement;
        DocNo: Code[20];
        DocNo2: Code[20];
        PostingDate: Date;
        TemplateName: Code[10];
        BatchName: Code[10];
        TemplateName3: Code[10];
        BatchName3: Code[10];
        JobNo: Code[20];
        JobTaskNo: Code[20];
        Text000: Label 'You must specify %1.';
        Text001: Label '%1 %2 must be %3.';
        CreatedGLLineCount: Integer;
        Text50151: Label 'There is no remaining usage on the job(s).';
        Text50152: Label '%1 lines were successfully transferred to the job journal.';

    procedure SetBatch(TemplateName2: Code[10]; BatchName2: Code[10])
    begin
        TemplateName3 := TemplateName2;
        BatchName3 := BatchName2;
    end;

    procedure SetDocNo(InputDocNo: Code[20])
    begin
        DocNo2 := InputDocNo;
    end;

    PROCEDURE InitDiffBuffer();
    BEGIN
        CLEAR(JobDiffBuffer);
        JobDiffBuffer[1].DELETEALL;
    END;

    PROCEDURE PostDiffBuffer(DocNo: Code[20]; PostingDate: Date; TemplateName: Code[10]; BatchName: Code[10]);
    VAR
        JobLedgEntry: Record "Job Ledger Entry";
        JobJournalLine: Record "Job Journal Line";
        JobJournalTemplate: Record "Job Journal Template";
        JobJournalBatch: Record "Job Journal Batch";
        NextLineNo: Integer;
    //LineNo: Integer;
    BEGIN
        IF JobDiffBuffer[1].FIND('-') THEN
            REPEAT
                JobLedgEntry.SETCURRENTKEY("Job No.", "Job Task No.");
                JobLedgEntry.SETRANGE("Job No.", JobDiffBuffer[1]."Job No.");
                JobLedgEntry.SETRANGE("Job Task No.", JobDiffBuffer[1]."Job Task No.");
                JobLedgEntry.SETRANGE("Entry Type", JobLedgEntry."Entry Type"::Usage);
                JobLedgEntry.SETRANGE(Type, JobDiffBuffer[1].Type);
                JobLedgEntry.SETRANGE("No.", JobDiffBuffer[1]."No.");
                JobLedgEntry.SETRANGE("Location Code", JobDiffBuffer[1]."Location Code");
                JobLedgEntry.SETRANGE("Variant Code", JobDiffBuffer[1]."Variant Code");
                JobLedgEntry.SETRANGE("Unit of Measure Code", JobDiffBuffer[1]."Unit of Measure code");
                JobLedgEntry.SETRANGE("Work Type Code", JobDiffBuffer[1]."Work Type Code");
                JobLedgEntry.SetRange(AMG_JobPlanningLineNo, JobDiffBuffer[1].AMG_JobPlanningLineNo);
                IF JobLedgEntry.FIND('-') THEN
                    REPEAT
                        JobDiffBuffer[1].Quantity := JobDiffBuffer[1].Quantity - JobLedgEntry.Quantity;
                        JobDiffBuffer[1]."Total Cost" := JobDiffBuffer[1]."Total Cost" - JobLedgEntry."Total Cost";
                    UNTIL JobLedgEntry.NEXT = 0;
                JobDiffBuffer[1].MODIFY;
            UNTIL JobDiffBuffer[1].NEXT = 0;
        JobJournalLine.LOCKTABLE;
        JobJournalLine.VALIDATE("Journal Template Name", TemplateName);
        JobJournalLine.VALIDATE("Journal Batch Name", BatchName);
        JobJournalLine.SETRANGE("Journal Template Name", JobJournalLine."Journal Template Name");
        JobJournalLine.SETRANGE("Journal Batch Name", JobJournalLine."Journal Batch Name");
        IF JobJournalLine.FINDLAST THEN
            NextLineNo := JobJournalLine."Line No." + 10000
        ELSE
            NextLineNo := 10000;

        IF JobDiffBuffer[1].FIND('-') THEN
            REPEAT
                IF (JobDiffBuffer[1].Quantity > 0) AND (JobDiffBuffer[1].Type IN [JobDiffBuffer[1].Type::Item, JobDiffBuffer[1].Type::Resource]) THEN BEGIN
                    CLEAR(JobJournalLine);
                    JobJournalLine."Journal Template Name" := TemplateName;
                    JobJournalLine."Journal Batch Name" := BatchName;
                    JobJournalTemplate.GET(TemplateName);
                    JobJournalBatch.GET(TemplateName, BatchName);
                    JobJournalLine."Source Code" := JobJournalTemplate."Source Code";
                    JobJournalLine."Reason Code" := JobJournalBatch."Reason Code";
                    JobJournalLine.DontCheckStdCost;
                    JobJournalLine.VALIDATE("Job No.", JobDiffBuffer[1]."Job No.");
                    JobJournalLine.VALIDATE("Job Task No.", JobDiffBuffer[1]."Job Task No.");
                    JobJournalLine.VALIDATE("Posting Date", PostingDate);
                    JobJournalLine.VALIDATE(Type, JobDiffBuffer[1].Type);
                    JobJournalLine.VALIDATE("No.", JobDiffBuffer[1]."No.");
                    JobJournalLine.VALIDATE("Variant Code", JobDiffBuffer[1]."Variant Code");
                    JobJournalLine.VALIDATE("Unit of Measure Code", JobDiffBuffer[1]."Unit of Measure code");
                    JobJournalLine.VALIDATE("Location Code", JobDiffBuffer[1]."Location Code");
                    IF JobDiffBuffer[1].Type = JobDiffBuffer[1].Type::Resource THEN
                        JobJournalLine.VALIDATE("Work Type Code", JobDiffBuffer[1]."Work Type Code");
                    JobJournalLine."Document No." := DocNo;
                    JobJournalLine.VALIDATE(Quantity, JobDiffBuffer[1].Quantity);
                    JobJournalLine.Validate("Gen. Bus. Posting Group", JobJournalBatch.AMG_GenBusPostingGroup); //30Dec2019 Fixed
                    JobJournalLine.VALIDATE("Job Planning Line No.", JobDiffBuffer[1].AMG_JobPlanningLineNo);

                    JobJournalLine."Line No." := NextLineNo;
                    NextLineNo := NextLineNo + 10000;
                    JobJournalLine.INSERT(TRUE);
                    //LineNo := LineNo + 1;
                    CreatedGLLineCount := CreatedGLLineCount + 1;
                END;
            UNTIL JobDiffBuffer[1].NEXT = 0;

        COMMIT;
        //IF LineNo = 0 THEN
        //    MESSAGE(Text50151)
        //ELSE
        //    MESSAGE(Text50152, LineNo);
    END;

    PROCEDURE CreateJT(JobPlanningLine: Record 1003);
    VAR
        Job: Record 167;
        JT: Record 1001;
        ResourceRec: Record Resource;
    BEGIN
        WITH JobPlanningLine DO BEGIN
            IF Type = Type::Text THEN
                EXIT;
            IF NOT "Schedule Line" THEN
                EXIT;

            // > Skip Use Time Sheet Resources
            Clear(ResourceRec);
            IF Type = Type::Resource Then Begin
                IF ResourceRec.Get("No.") then
                    IF ResourceRec."Use Time Sheet" then
                        exit;
            End;
            // < Skip Use Time Sheet Resources

            Job.GET("Job No.");
            JT.GET("Job No.", "Job Task No.");
            JobDiffBuffer[1]."Job No." := "Job No.";
            JobDiffBuffer[1]."Job Task No." := "Job Task No.";
            JobDiffBuffer[1].Type := Type;
            JobDiffBuffer[1]."No." := "No.";
            JobDiffBuffer[1]."Location Code" := "Location Code";
            JobDiffBuffer[1]."Variant Code" := "Variant Code";
            JobDiffBuffer[1]."Unit of Measure code" := "Unit of Measure Code";
            JobDiffBuffer[1]."Work Type Code" := "Work Type Code";
            JobDiffBuffer[1].Quantity := Quantity;
            JobDiffBuffer[1]."Total Cost" := "Total Cost";
            JobDiffBuffer[1].AMG_JobPlanningLineNo := "Line No.";
            JobDiffBuffer[2] := JobDiffBuffer[1];
            IF JobDiffBuffer[2].FIND THEN BEGIN
                JobDiffBuffer[2].Quantity := JobDiffBuffer[2].Quantity + JobDiffBuffer[1].Quantity;
                JobDiffBuffer[2]."Total Cost" := JobDiffBuffer[2]."Total Cost" + JobDiffBuffer[1]."Total Cost";
                JobDiffBuffer[2].MODIFY;
            END ELSE
                JobDiffBuffer[1].INSERT;
        END;
    END;
}

