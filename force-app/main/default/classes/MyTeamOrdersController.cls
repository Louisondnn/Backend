public with sharing class MyTeamOrdersController {
    public Decimal sumOrders { get; private set; }

    public MyTeamOrdersController() {
        Id currentUserId = UserInfo.getUserId();

        // Récupère l'équipe du commercial
        String team = [SELECT Team__c FROM User WHERE Id = :currentUserId LIMIT 1].Team__c;

        // Tous les utilisateurs de cette équipe
        Set<Id> teamUserIds = new Map<Id, User>(
            [SELECT Id FROM User WHERE Team__c = :team]
        ).keySet();

        // Somme des commandes
        List<AggregateResult> agg = [
            SELECT SUM(Montant__c) total
            FROM Order
            WHERE Status = 'Ordered' AND OwnerId IN :teamUserIds
        ];

        sumOrders = (agg.isEmpty() || agg[0].get('total') == null)
            ? 0
            : (Decimal)agg[0].get('total');
    }
}
