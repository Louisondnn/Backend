public with sharing class MyTeamOrdersController {
    public Decimal sumOrders { get; private set; }

    public MyTeamOrdersController() {
        Id currentUserId = UserInfo.getUserId();

        String team = [SELECT Team__c FROM User WHERE Id = :currentUserId LIMIT 1].Team__c;
        Set<Id> teamUserIds = new Map<Id,User>(
            [SELECT Id FROM User WHERE Team__c = :team]
        ).keySet();

        AggregateResult ar = [
            SELECT SUM(Montant__c) total
            FROM Order
            WHERE Status = 'Ordered' AND OwnerId IN :teamUserIds
        ];

        sumOrders = (ar.get('total') == null) ? 0 : (Decimal)ar.get('total');
    }
}
