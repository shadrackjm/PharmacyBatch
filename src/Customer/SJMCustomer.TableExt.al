namespace ShadrackMballah.PharmacyBatch;

using Microsoft.Sales.Customer;

tableextension 50100 "SJM Customer" extends Customer
{
    fields
    {
        field(50100; "SJM Min. Shelf Life (Days)"; Integer)
        {
            Caption = 'Min. Shelf Life (Days)';
            DataClassification = CustomerContent;
            MinValue = 0;
            Tooltip = 'Specifies the minimum number of days a lot must have left before its expiration date to be shipped to this customer.';
        }
    }
}