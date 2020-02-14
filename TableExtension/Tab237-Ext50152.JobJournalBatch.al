tableextension 50152 tableextension50152 extends "Job Journal Batch"
{
    fields
    {
        field(50151; "AMG_GenBusPostingGroup"; Code[20])
        {
            Caption = 'Gen. Business Posting Group';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Business Posting Group";
        }
    }

}