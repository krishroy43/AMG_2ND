tableextension 50157 tableextension50157 extends "Purchase Line"
{
    fields
    {
        // Purchase Requisition. //
        field(50151; AMG_InitSourceNo; Code[20])
        {
            Caption = 'Init Source No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50152; AMG_InitSourceLineNo; Integer)
        {
            Caption = 'Init Source Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        // Option to Short Close and cancelation of Purchase order. 
        //In case of Vendor refuse to deliver the goods partially or completely.
        field(50153; AMG_ShortClosed; Boolean)
        {
            Caption = 'Short Closed';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50154; AMG_Cancelled; Boolean)
        {
            Caption = 'Cancelled';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50155; AMG_OriginalQty; Decimal)
        {
            Caption = 'Original Qty.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50156; AMG_ShortClosedQty; Decimal)
        {
            Caption = 'Short Closed Qty.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50157; AMG_CancelledQty; Decimal)
        {
            Caption = 'Cancelled Qty.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50158; AMG_AppliedForClose; Boolean)
        {
            Caption = 'Applied For Close';
            DataClassification = ToBeClassified;
        }
    }
}