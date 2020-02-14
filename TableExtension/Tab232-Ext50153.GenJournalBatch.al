tableextension 50153 tableextension50153 extends "Gen. Journal Batch"
{
    fields
    {
        field(50151; "AMG_GenBusPostingGroup"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            DataClassification = ToBeClassified;
            TableRelation = "Gen. Business Posting Group";
        }
    }

}