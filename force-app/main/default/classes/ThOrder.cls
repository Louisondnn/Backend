public with sharing class ThOrder {

    //  Recalcule le chiffre d'affaires des comptes liés aux commandes
    public static void recalcAccountCA(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) return;

        Map<Id, Decimal> caMap = new Map<Id, Decimal>();

        for (Order o : [
            SELECT AccountId, OrderAmount__c, Status
            FROM Order
            WHERE Id IN :orderIds
              AND Status = 'Ordered'
              AND AccountId != null
        ]) {
            Decimal amount = (o.OrderAmount__c != null) ? o.OrderAmount__c : 0;
            caMap.put(o.AccountId, caMap.containsKey(o.AccountId)
                ? caMap.get(o.AccountId) + amount
                : amount);
        }

        if (caMap.isEmpty()) return;

        List<Account> accountsToUpdate = [
            SELECT Id, Chiffre_d_affaire__c
            FROM Account
            WHERE Id IN :caMap.keySet()
        ];

        for (Account a : accountsToUpdate) {
            a.Chiffre_d_affaire__c = caMap.get(a.Id);
        }

        update accountsToUpdate;
    }
}
