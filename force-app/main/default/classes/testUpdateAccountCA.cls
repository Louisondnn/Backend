@IsTest
public class TestUpdateAccountCA {

    @IsTest
    static void testUpdateAccountCA() {
        // Création d'un compte test
        Account acc = new Account(Name='Test Account', Chiffre_d_affaire__c=0);
        insert acc;

        //  Création de 5 commandes avec un champ personnalisé Montant__c
        List<Order> orders = new List<Order>();
        for (Integer i=0; i<5; i++) {
            orders.add(new Order(
                AccountId = acc.Id,
                Status = 'Ordered',
                Montant__c = 100 + i*10 // <-- Champ personnalisé à créer
            ));
        }
        insert orders;

        // Vérification du trigger
        acc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id=:acc.Id];
        System.assertEquals(550, acc.Chiffre_d_affaire__c,
            'Le chiffre d\'affaires doit être la somme des Montant__c');

        // 4️ Test batch
        Test.startTest();
        Database.executeBatch(new UpdateAccounts(), 2);
        Test.stopTest();

        acc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id=:acc.Id];
        Integer nbOrders = [SELECT COUNT() FROM Order WHERE AccountId = :acc.Id];
        System.debug('Nombre de commandes créées = ' + nbOrders);
        System.assertEquals(5, nbOrders); // ou 100 si tu en crées 100

        System.assertEquals(550, acc.Chiffre_d_affaire__c,
            'Le batch doit recalculer correctement le chiffre d\'affaires');
    }
}
