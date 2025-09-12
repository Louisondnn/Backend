global class UpdateAccounts implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Tous les comptes
        return Database.getQueryLocator([SELECT Id FROM Account]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Account> accounts = (List<Account>)scope;
        Map<Id, Decimal> sumMap = new Map<Id, Decimal>();

        // Récupérer toutes les commandes Ordered pour ces comptes en une seule requête
        List<Order> orders = [SELECT AccountId, Montant__c FROM Order WHERE AccountId IN :accounts AND Status = 'Ordered'];

        for (Order o : orders) {
            if (o.Montant__c != null) {
                sumMap.put(o.AccountId, (sumMap.get(o.AccountId) == null ? 0 : sumMap.get(o.AccountId)) + o.Montant__c);
            }
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : accounts) {
            acc.Chiffre_d_affaire__c = sumMap.containsKey(acc.Id) ? sumMap.get(acc.Id) : 0;
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Optionnel : log ou email
    }
}
