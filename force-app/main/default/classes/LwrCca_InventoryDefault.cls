/**
 * @description       : Default Inventory class for B2B Commerce LWR CCA Integration. Currently this is only calling into the base class.
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 02-29-2024
 * @last modified by  : Tom Zarr
**/
public class LwrCca_InventoryDefault extends commerce_inventory.CommerceInventoryService {

    public override commerce_inventory.UpsertReservationResponse upsertReservation(commerce_inventory.UpsertReservationRequest upsertReservationRequest,
                                                                   commerce_inventory.InventoryReservation currentReservation,
                                                                   String reservationChangeType)
    {
        return super.upsertReservation(upsertReservationRequest, currentReservation, reservationChangeType);
    }

    public override commerce_inventory.DeleteReservationResponse deleteReservation(String reservationId,  commerce_inventory.InventoryReservation currentReservation)
    {
        return super.deleteReservation(reservationId, currentReservation);
    }

    public override commerce_inventory.InventoryReservation getReservation(String reservationId)
    {
        return super.getReservation(reservationId);
    }

    public override commerce_inventory.InventoryCheckAvailability checkInventory(commerce_inventory.InventoryCheckAvailability request)
    {
        return super.checkInventory(request);
    }

    public override commerce_inventory.InventoryLevelsResponse getInventoryLevel(commerce_inventory.InventoryLevelsRequest request)
    {
        return super.getInventoryLevel(request);
    }
}