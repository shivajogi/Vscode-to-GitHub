public class AccountController {
    
    /**
     * Generate a snapshot shell of the newly created Account.  This will be
     * primarily populated via formula fields and used for global search
     * actions by users who may not have access to the actual Account record.
     * 
     * @param accounts Collection of newly inserted Accounts.
     */
    public void generateSnapshots( List<Account> accounts ) {
        
        // Ignore if collection is empty (should never happen).
        if( accounts == null || accounts.size() == 0 ) return;
        
        // Initialize collection of Accounts that need a snapshot.
        List<Account> accountsNeedingSnapshot = new List<Account>();
        
        // Determine unique set of ids for existing Accounts and which Accounts
        // need a snapshot by virtue of being newly created.
        Set<Id> accountIds = new Set<Id>();
        for( Account account : accounts ) {
            if( account.Id != null ) {
                accountIds.add( account.Id );
            } else {
                accountsNeedingSnapshot.add( account );
            }
        }
        
        // Evaluate existing Accounts to see which ones need a snapshot.
        if( accountIds != null && accountIds.size() > 0 ) {
            
            // Query all affected Accounts to see which ones need a snapshot.
            Map<Id,Account> accountsWithSnapshots =	new Map<Id,Account> ([
                                                                            SELECT	Id,
                                                                                    (
                                                                                        SELECT	Id
                                                                                        FROM	Account_Snapshot__r
                                                                                    )
                                                                            FROM	Account
                                                                            WHERE	Id IN :accountIds
                                                                        ]);
            
            // Iterate over collection of affected Accounts to see if an existing
            // snapshot already exists.
            for( Account account : accounts ) {
                
                // Ignore Accounts that don't have an id.
                if( account.Id != null ) {
                    
                    // Grab the existing Account record.
                    Account oldAccount = accountsWithSnapshots.get( account.Id );
                    
                    // Check to see if there already is a snapshot.
                    if( oldAccount.Account_Snapshot__r == null || oldAccount.Account_Snapshot__r.size() == 0 ) {
                        accountsNeedingSnapshot.add( account );
                    }
                    
                }
                
            }
            
        }
        
        // Make sure there are Accounts that actually need a snapshot.
        if( accountsNeedingSnapshot == null || accountsNeedingSnapshot.size() == 0 ) return;
        
        // Initialize collection of new snapshots.
        List<Account_Snapshot__c> snapshots = new List<Account_Snapshot__c>();
        
        // Iterate over newly created Accounts.
        for( Account account : accountsNeedingSnapshot ) {
            
            // Build a new snapshot.
            Account_Snapshot__c snapshot = new Account_Snapshot__c();
            snapshot.Name = account.Name;
            snapshot.Account__c = account.Id;
            
            // Add snapshot to collection.
            snapshots.add( snapshot );
            
        }
        
        // Insert snapshots.
        if( snapshots != null && snapshots.size() > 0 ) {
            insert snapshots;
        }
        
    }

}