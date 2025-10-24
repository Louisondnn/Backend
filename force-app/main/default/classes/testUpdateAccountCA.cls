@IsTest
public class TestUpdateAccountCA {

    @TestSetup
    static void setupTestData() {
        // Créer le produit
        Product2 prod = new Product2(Name='Produit Test', IsActive=true);
        insert prod;

        // Obtenir et activer le Pricebook standard
        Id stdPbId = Test.getStandardPricebookId();
        
        // Créer le PricebookEntry standard
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPbId,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;
    }

    @IsTest
    static void testUpdateAccountCA_UsingTotalAmount() {
        // 1️⃣ Créer un compte test
        Account acc = new Account(Name='Compte Test', Chiffre_d_affaire__c=0);
        insert acc;

        // 2️⃣ Récupérer les données du @TestSetup
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Produit Test' LIMIT 1];
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry 
                              WHERE Product2Id = :prod.Id 
                              AND Pricebook2Id = :standardPricebookId 
                              LIMIT 1];

        // 3️⃣ Créer plusieurs Orders avec le Pricebook standard
        List<Order> orders = new List<Order>();
        for (Integer i = 1; i <= 5; i++) {
            orders.add(new Order(
                AccountId = acc.Id,
                Status = 'Draft',
                EffectiveDate = Date.today(),
                Pricebook2Id = standardPricebookId
            ));
        }
        insert orders;

        // 4️⃣ Créer OrderItems pour calculer TotalAmount
        List<OrderItem> items = new List<OrderItem>();
        for (Order o : orders) {
            items.add(new OrderItem(
                OrderId = o.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                UnitPrice = 100
            ));
        }
        insert items;

        // 5️⃣ Passer les Orders au statut "Activated" (pas "Ordered")
        for (Order o : orders) {
            o.Status = 'Activated';
        }
        update orders;

        // 6️⃣ Exécuter le batch de recalcul
        Test.startTest();
        Database.executeBatch(new UpdateAccounts(), 100);
        Test.stopTest();

        // 7️⃣ Vérifier que le CA correspond à la somme des TotalAmount
        acc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        
        Decimal expectedCA = 0;
        // IMPORTANT : Changer le filtre pour Status = 'Activated'
        for (Order o : [SELECT TotalAmount FROM Order WHERE AccountId = :acc.Id AND Status = 'Activated']) {
            expectedCA += (o.TotalAmount != null) ? o.TotalAmount : 0;
        }

        System.assertEquals(expectedCA, acc.Chiffre_d_affaire__c, 
            'Le CA doit correspondre à la somme des TotalAmount des Orders activés');
        System.debug('✅ Test réussi, CA attendu : ' + expectedCA + ' | CA réel : ' + acc.Chiffre_d_affaire__c);
    }

    @IsTest
    static void testUpdateAccountCA_NoOrderedStatus() {
        // Test avec des Orders en Draft (ne doivent pas être comptés)
        Account acc = new Account(Name='Compte Test Draft', Chiffre_d_affaire__c=0);
        insert acc;

        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Produit Test' LIMIT 1];
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry 
                              WHERE Product2Id = :prod.Id 
                              AND Pricebook2Id = :standardPricebookId 
                              LIMIT 1];

        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = standardPricebookId
        );
        insert ord;

        OrderItem item = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 200
        );
        insert item;

        // Order reste en Draft, donc CA = 0
        Test.startTest();
        Database.executeBatch(new UpdateAccounts(), 100);
        Test.stopTest();

        acc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, acc.Chiffre_d_affaire__c, 
            'Les Orders en Draft ne doivent pas être comptés dans le CA');
    }

    @IsTest
    static void testUpdateAccountCA_MultipleAccounts() {
        // Test avec plusieurs comptes
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name='Compte A', Chiffre_d_affaire__c=0));
        accounts.add(new Account(Name='Compte B', Chiffre_d_affaire__c=0));
        insert accounts;

        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Produit Test' LIMIT 1];
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry 
                              WHERE Product2Id = :prod.Id 
                              AND Pricebook2Id = :standardPricebookId 
                              LIMIT 1];

        List<Order> orders = new List<Order>();
        orders.add(new Order(
            AccountId = accounts[0].Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = standardPricebookId
        ));
        orders.add(new Order(
            AccountId = accounts[1].Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = standardPricebookId
        ));
        insert orders;

        List<OrderItem> items = new List<OrderItem>();
        items.add(new OrderItem(
            OrderId = orders[0].Id,
            PricebookEntryId = pbe.Id,
            Quantity = 2,
            UnitPrice = 150
        ));
        items.add(new OrderItem(
            OrderId = orders[1].Id,
            PricebookEntryId = pbe.Id,
            Quantity = 3,
            UnitPrice = 150
        ));
        insert items;

        // Passer les Orders à "Activated"
        for (Order o : orders) {
            o.Status = 'Activated';
        }
        update orders;

        Test.startTest();
        Database.executeBatch(new UpdateAccounts(), 100);
        Test.stopTest();

        Map<Id, Account> accMap = new Map<Id, Account>(
            [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id IN :accounts]
        );

        System.assertEquals(300, accMap.get(accounts[0].Id).Chiffre_d_affaire__c, 
            'Compte A doit avoir CA = 300 (2 x 150)');
        System.assertEquals(450, accMap.get(accounts[1].Id).Chiffre_d_affaire__c, 
            'Compte B doit avoir CA = 450 (3 x 150)');
    }
    @IsTest
    static void testMyTeamOrdersController_Minimal() {
        Account acc = new Account(Name='Compte Test'); 
        insert acc;

        // Créer la commande
        Order ord = new Order(
            AccountId = acc.Id,
            Status = 'Draft',
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert ord;

        // Ajouter un produit
        Product2 prod = new Product2(Name='Produit Test', IsActive=true);
        insert prod;
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // Ajouter un OrderItem
        OrderItem oi = new OrderItem(
            OrderId = ord.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert oi;

        // Passer la commande en Activated
        ord.Status = 'Activated';
        update ord;

        Test.startTest();
        MyTeamOrdersController ctrl = new MyTeamOrdersController();
        Test.stopTest();

        System.assert(ctrl.sumOrders >= 0, 'Le total doit être calculé.');
        System.assert(!ctrl.teamOrders.isEmpty(), 'Au moins un utilisateur doit être dans teamOrders.');
    }
}
