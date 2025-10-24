trigger CalculMontant on Order (after insert, after update) {
    Set<Id> orderIds = new Set<Id>();
    for(Order o : Trigger.new){
        orderIds.add(o.Id);
    }
    ThOrder.recalcAccountCA(orderIds);
}
