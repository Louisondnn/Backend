public class UpdateAccountCAUtil {
    public static void recalcAccounts(Set<Id> accountIds) {
        if (accountIds.isEmpty()) return;

        // Récupérer les comptes
        Map<Id, Account> accountsMap = new Map<Id, Account>(
            [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accountIds]
        );

        // Récupérer toutes les commandes Ordered pour ces comptes
        List<Order> relatedOrders = [
            SELECT AccountId, Montant__c 
            FROM Order 
            WHERE AccountId IN :accountIds AND Status = 'Ordered'
        ];

        Map<Id, Decimal> sumMap = new Map<Id, Decimal>();
        for (Order o : relatedOrders) {
            if (o.Montant__c != null) {
                sumMap.put(o.AccountId, (sumMap.get(o.AccountId) == null ? 0 : sumMap.get(o.AccountId)) + o.Montant__c);
            }
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountsMap.keySet()) {
            Account acc = accountsMap.get(accId);
            acc.Chiffre_d_affaire__c = sumMap.containsKey(accId) ? sumMap.get(accId) : 0;
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
