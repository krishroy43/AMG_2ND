page 50151 AMG_PurchRequisitionList
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = AMG_PurchRequisitionHeader;
    Caption = 'Purchase Requisition List';
    SourceTableView = sorting("No.");
    CardPageId = AMG_PurchRequisitionCard;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved purchase requisition record, according to the specified number series.';
                }
                field("Requisition Date"; "Requisition Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when purchase requisition is created.';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Shortcut Dimension 3 Code"; "Shortcut Dimension 3 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for Shortcut Dimension 3, which is codes that you set up in the General Ledger Setup window.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Import Purchase Requsision")
            {
                RunObject = xmlport "Import CSV";
                Promoted = true;
                PromotedOnly = true;
                ApplicationArea = ALL;
                Image = ImportExcel;
                trigger OnAction()
                begin


                end;
            }
            action("Export Layout")
            {
                RunObject = xmlport "Export Layout Csv";
                Promoted = true;
                PromotedOnly = true;
                ApplicationArea = all;
                Image = ExportToExcel;
                trigger OnAction()
                begin


                end;
            }
        }
    }
    var

}