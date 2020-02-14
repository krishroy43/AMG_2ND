tableextension 50154 tableextension50154 extends "Job Task"
{
    fields
    {
        field(50151; "Schedule Quantity"; Decimal)
        {
            Caption = 'Schedule Quantity';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum ("Job Planning Line".Quantity WHERE("Job No." = FIELD("Job No."), "Job Task No." = FIELD("Job Task No."), "Job Task No." = FIELD(FILTER(Totaling)), "Schedule Line" = CONST(true), "Planning Date" = FIELD("Planning Date Filter")));
        }
        field(50152; "Usage Quantity"; Decimal)
        {
            Caption = 'Usage Quantity';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum ("Job Ledger Entry".Quantity WHERE("Job No." = FIELD("Job No."), "Job Task No." = FIELD("Job Task No."), "Job Task No." = FIELD(FILTER(Totaling)), "Entry Type" = CONST(Usage), "Posting Date" = FIELD("Posting Date Filter")));
        }
    }
}