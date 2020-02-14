pageextension 50160 pageextension50160 extends "Job G/L Journal"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast("F&unctions")
        {
            action(CalcRemainingUsage)
            {
                ApplicationArea = Jobs;
                Caption = 'Calc. Remaining Usage';
                Ellipsis = true;
                Image = CalculateRemainingUsage;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Calculate the remaining usage for the job. The batch job calculates, for each job task, the difference between scheduled usage of expenses and actual usage posted in job ledger entries. The remaining usage is then displayed in the job g/l journal from where you can post it.';

                trigger OnAction()
                var
                    JobGLCalcRemainingUsage: Report AMG_JobGLCalcRemainingUsage;
                begin
                    TestField("Journal Template Name");
                    TestField("Journal Batch Name");
                    Clear(JobGLCalcRemainingUsage);
                    JobGLCalcRemainingUsage.SetBatch("Journal Template Name", "Journal Batch Name");
                    JobGLCalcRemainingUsage.SetDocNo("Document No.");
                    JobGLCalcRemainingUsage.RunModal;
                end;
            }
        }
    }

    var
        myInt: Integer;
}