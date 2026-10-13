namespace ShadrackMballah.PharmacyBatch;

using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Tracking;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;

codeunit 50100 "SJM Shelf Life Check"
{
    var
        ShelfLifeErr: Label 'Lot %1 of item %2 expires on %3. Customer %4 requires at least %5 days of shelf life, so lots must not expire before %6.', Comment = '%1 = Lot No., %2 = Item No., %3 = Expiration Date, %4 = Customer No., %5 = Min. Shelf Life (Days), %6 = Earliest allowed expiration date';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckSalesDoc', '', false, false)]
    local procedure CheckShelfLifeOnAfterCheckSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        if not SalesHeader.Ship then
            exit;

        CheckMinShelfLife(SalesHeader);
    end;

    local procedure CheckMinShelfLife(SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        ReservationEntry: Record "Reservation Entry";
        EarliestAllowedDate: Date;
        ExpirationDate: Date;
    begin
        Customer.SetLoadFields("SJM Min. Shelf Life (Days)");
        if not Customer.Get(SalesHeader."Sell-to Customer No.") then
            exit;
        if Customer."SJM Min. Shelf Life (Days)" = 0 then
            exit;

        EarliestAllowedDate := SalesHeader."Posting Date" + Customer."SJM Min. Shelf Life (Days)";

        ReservationEntry.SetLoadFields("Item No.", "Lot No.");
        ReservationEntry.SetRange("Source Type", Database::"Sales Line");
        ReservationEntry.SetRange("Source Subtype", SalesHeader."Document Type".AsInteger());
        ReservationEntry.SetRange("Source ID", SalesHeader."No.");
        ReservationEntry.SetFilter("Lot No.", '<>%1', '');
        ReservationEntry.SetFilter("Qty. to Handle (Base)", '<>0');
        if ReservationEntry.FindSet() then
            repeat
                ExpirationDate := GetLotExpirationDate(ReservationEntry."Item No.", ReservationEntry."Lot No.");
                if (ExpirationDate <> 0D) and (ExpirationDate < EarliestAllowedDate) then
                    Error(ShelfLifeErr, ReservationEntry."Lot No.", ReservationEntry."Item No.", ExpirationDate,
                        Customer."No.", Customer."SJM Min. Shelf Life (Days)", EarliestAllowedDate);
            until ReservationEntry.Next() = 0;
    end;

    local procedure GetLotExpirationDate(ItemNo: Code[20]; LotNo: Code[50]): Date
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetLoadFields("Expiration Date");
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Lot No.", LotNo);
        ItemLedgerEntry.SetRange(Positive, true);
        ItemLedgerEntry.SetFilter("Expiration Date", '<>%1', 0D);
        if ItemLedgerEntry.FindFirst() then
            exit(ItemLedgerEntry."Expiration Date");
    end;
}