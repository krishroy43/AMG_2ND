page 50152 AMG_PurchRequisitionCard
{
    PageType = Document;
    Caption = 'Purchase Requisition';
    PopulateAllFields = true;
    RefreshOnActivate = true;
    SourceTableView = sorting("No.");
    SourceTable = AMG_PurchRequisitionHeader;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved purchase requisition record, according to the specified number series.';
                }
                field("Requisition Date"; "Requisition Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when purchase requisition is created.';
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
                field("Coordinator Name"; "Coordinator Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the coordinator.';
                    // ShowMandatory = true;
                }
            }
            part("Requisition Line"; 50153)
            {
                SubPageLink = "Document No." = FIELD("No.");
                SubPageView = SORTING("Document No.");
                UpdatePropagation = Both;
                ApplicationArea = All;
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
                ApplicationArea = All;
                Caption = 'Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to purchase documents to distribute costs and analyze transaction history.';

                trigger OnAction()
                begin
                    ShowDocDim;
                end;
            }
            action(CreatePurchaseQuote)
            {
                ApplicationArea = All;
                Caption = 'Create Purch. Quote';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create purchase quote based on the given information in purchase requisition.';

                trigger OnAction()
                var
                    SelectedPurchReqLine: Record AMG_PurchRequisitionLine;
                    MiscMgmt: Codeunit AMG_MiscManagement;
                    PurchType: Option Quote,"Order";
                begin
                    PurchType := PurchType::Quote;
                    CurrPage."Requisition Line".PAGE.SETSELECTIONFILTER(SelectedPurchReqLine);
                    CheckMandatoryFields(Rec, SelectedPurchReqLine);
                    // SelectedPurchReqLine.CheckOrderExist(SelectedPurchReqLine);
                    MiscMgmt.CreatePurchDocument(Rec, SelectedPurchReqLine, PurchType);
                end;
            }
            action(CreatePurchaseOrder)
            {
                ApplicationArea = Dimensions;
                Caption = 'Create Purch. Order';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Create purchase order based on the given information in purchase requisition.';

                trigger OnAction()
                var
                    SelectedPurchReqLine: Record AMG_PurchRequisitionLine;
                    MiscMgmt: Codeunit AMG_MiscManagement;
                    PurchType: Option Quote,"Order";
                begin
                    PurchType := PurchType::Order;
                    CurrPage."Requisition Line".PAGE.SETSELECTIONFILTER(SelectedPurchReqLine);
                    CheckMandatoryFields(Rec, SelectedPurchReqLine);
                    // SelectedPurchReqLine.CheckOrderExist(SelectedPurchReqLine);
                    MiscMgmt.CreatePurchDocument(Rec, SelectedPurchReqLine, PurchType);
                end;
            }
            action(PurcahseQuotes)
            {
                Caption = 'Purcahse Quotes';
                ApplicationArea = All;
                Image = Quote;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Specifies the purcahse quotes, which are linked with the requisitoin document.';
                trigger OnAction()
                var
                    PurcahseHeaderRec: Record "Purchase Header";
                begin
                    PurcahseHeaderRec.Reset();
                    PurcahseHeaderRec.SetRange("Document Type", PurcahseHeaderRec."Document Type"::Quote);
                    PurcahseHeaderRec.SetRange(AMG_InitSourceNo, Rec."No.");
                    if PurcahseHeaderRec.FindSet() then
                        Page.RunModal(Page::"Purchase Quotes", PurcahseHeaderRec);
                end;
            }
            action(PurcahseOrders)
            {
                Caption = 'Purcahse Orders';
                ApplicationArea = All;
                Image = Order;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Specifies the purcahse Orders, which are linked with the requisitoin document.';
                trigger OnAction()
                var
                    PurcahseHeaderRec: Record "Purchase Header";
                begin
                    PurcahseHeaderRec.Reset();
                    PurcahseHeaderRec.SetRange("Document Type", PurcahseHeaderRec."Document Type"::"Order");
                    PurcahseHeaderRec.SetRange(AMG_InitSourceNo, Rec."No.");
                    if PurcahseHeaderRec.FindSet() then
                        Page.RunModal(Page::"Purchase Order List", PurcahseHeaderRec);
                end;
            }
        }
    }
}