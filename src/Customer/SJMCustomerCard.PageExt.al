namespace ShadrackMballah.PharmacyBatch;

using Microsoft.Sales.Customer;

pageextension 50100 "SJM Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(Shipping)
        {
                field("SJM Min. Shelf Life (Days)"; Rec."SJM Min. Shelf Life (Days)")
                {
                    ApplicationArea = All;
                }
        }
    }
}