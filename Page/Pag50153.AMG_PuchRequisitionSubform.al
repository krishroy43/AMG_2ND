page 50153 AMG_PurchRequisitionSubform
{
    AutoSplitKey = true;
    Caption = 'Purchase Requisition Line';
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = AMG_PurchRequisitionLine;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(QuoteCreated; QuoteCreated)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows weather the line is linked with any purchase quote.';
                }
                field(OrderCreated; OrderCreated)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows weather the line is linked with any purchase order.';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line type.';
                    ShowMandatory = true;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of a general ledger account or item,depending on what you selected in the Type field.';
                    ShowMandatory = true;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the entry.';
                    ShowMandatory = true;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how each unit of the item is measured, such as in pieces.';
                    ShowMandatory = true;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a code for the location where you want the items to be placed when they are received.';
                    ShowMandatory = true;
                }
                field(Inventory; Inventory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many units, such as pieces, boxes, or cans, of the item are in inventory.';
                    ShowMandatory = true;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of units of the item specified on the line.';
                    ShowMandatory = true;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    ShowMandatory = true;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    ShowMandatory = true;
                }
                field("Shortcut Dimension 3 Code"; "Shortcut Dimension 3 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 3, which is codes that you set up in the General Ledger Setup window.';
                    ShowMandatory = true;
                }
                field("Shortcut Dimension 4 Code"; "Shortcut Dimension 4 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 4, which is codes that you set up in the General Ledger Setup window.';
                    ShowMandatory = true;
                }
                field("Shortcut Dimension 5 Code"; "Shortcut Dimension 5 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 5, which is codes that you set up in the General Ledger Setup window.';
                    ShowMandatory = true;
                }
                field("Shortcut Dimension 6 Code"; "Shortcut Dimension 6 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 6, which is codes that you set up in the General Ledger Setup window.';
                    ShowMandatory = true;
                }
                field("Shortcut Dimension 7 Code"; "Shortcut Dimension 7 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 7, which is codes that you set up in the General Ledger Setup window.';
                    ShowMandatory = true;
                }
                field("Shortcut Dimension 8 Code"; "Shortcut Dimension 8 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 8, which is codes that you set up in the General Ledger Setup window.';
                    ShowMandatory = true;
                }
                field(ROB; ROB)
                {
                    ApplicationArea = All;
                }
                field(Remarks; Remarks)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Dimensions)
            {
                AccessByPermission = TableData Dimension = R;
                ApplicationArea = Dimensions;
                Caption = 'Dimensions';
                Image = Dimensions;
                ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to purchase documents to distribute costs and analyze transaction history.';

                trigger OnAction()
                begin
                    ShowDimensions;
                end;
            }
        }
    }
}


