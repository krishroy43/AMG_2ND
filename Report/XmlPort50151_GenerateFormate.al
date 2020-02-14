xmlport 50154 "Genarate Format"
{
    Format = VariableText;
    Direction = Export;
    FieldSeparator = '<TAB>';
    UseRequestPage = false;


    schema
    {
        textelement("Root")
        {
            tableelement(AMG_PurchRequisitionHeader; AMG_PurchRequisitionHeader)
            {
                fieldattribute(vessalNo; AMG_PurchRequisitionHeader."Shortcut Dimension 1 Code") { }
                tableelement(AMG_PurchRequisitionLine; AMG_PurchRequisitionLine)
                {
                    fieldattribute(V_Type; AMG_PurchRequisitionLine.Type) { }
                    fieldattribute(Impa; AMG_PurchRequisitionLine."No.") { }
                    fieldattribute(Qty; AMG_PurchRequisitionLine.Quantity) { }
                    fieldattribute(UOM; AMG_PurchRequisitionLine."Unit of Measure Code") { }
                    fieldattribute(Rob; AMG_PurchRequisitionLine.ROB) { }
                    fieldattribute(Remarks; AMG_PurchRequisitionLine.Remarks) { }
                }
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {

                }
            }
        }
    }

    var
        myInt: Integer;
        Vessel_No: Text;
        V_Type: Text;
        IMPA: Text;
        Qty: Decimal;
        umo: Text;
        ROB: Text;
        Remarks: Text;
        PurchReqLineRec: Record AMG_PurchRequisitionLine;
}