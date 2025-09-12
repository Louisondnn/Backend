//triggerHandler 
// un trigger par object
// corriger bug
// inserer command masse +100 
// reproduire bugs 
// ● affichage des commandes d’une équipe par commercial. GRAPHIQUE
//  My team orders
// somme des commande a afficher sur accounts via page 
// faire captures script + tests pour la soutenance 
// nettoyage 
public with sharing class ThAccount {
    public static void run(List<Order> newOrders,
                           Boolean isBefore,
                           Boolean isAfter,
                           Boolean isInsert,
                           Boolean isUpdate) {

        if (isBefore && isUpdate) {
            for (Order o : newOrders) {
                if (o.TotalAmount == null || o.ShipmentCost__c == null) {
                    o.addError('TotalAmount et ShipmentCost__c sont requis pour NetAmount__c');
                    continue;
                }
                o.NetAmount__c = o.TotalAmount - o.ShipmentCost__c;
            }
        }

        if (isAfter && (isInsert || isUpdate)) {
            Set<Id> accountIds = new Set<Id>();
            for (Order o : newOrders) {
                if (o.AccountId != null && o.Status == 'Ordered') {
                    accountIds.add(o.AccountId);
                }
            }
            if (!accountIds.isEmpty()) {
                // Appel de ta méthode utilitaire existante
                UpdateAccountCAUtil.recalcAccounts(accountIds);
            }
        }
    }
}



    // Set<Id> accountIds = new Set<Id>();
    // for (Order o : Trigger.new) {
    //     if (o.AccountId != null && o.Status == 'Ordered') {
    //         accountIds.add(o.AccountId);
    //     }
    // }

    // if (!accountIds.isEmpty()) {
    //     // Réutilise la méthode utilitaire pour recalculer le CA
    //     UpdateAccountCA.recalcAccounts(accountIds);
    // }


    //     for (Order o : Trigger.new) {
    //     // Si les champs nécessaires au calcul sont manquants, on passe au suivant
    //     if (o.TotalAmount == null || o.ShipmentCost__c == null) {
    //         continue;
    //     }
        
    //     // Calcul du montant net
    //     o.NetAmount__c = o.TotalAmount - o.ShipmentCost__c;
    // }