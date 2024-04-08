/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Melissa Riggins
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account brandNewAccount = new Account();

        // Set the Name of the Account
        brandNewAccount.Name = 'Hello World Inc.';

        // Insert the Account into the database
        insert brandNewAccount;

        return brandNewAccount.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the Name and Industry
        Account brandNewAccount = new Account(Name = name, Industry = industry);

        // Insert the Account into the database
        insert brandNewAccount;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact brandNewContact = new Contact();

        // Set the First and Last name for the contact
        brandNewContact.FirstName = 'Codey';
        brandNewContact.LastName = 'the Bear';

        // Set the AccountId field to the given accountId
        brandNewContact.AccountId = accountId;

        // Insert the Contact into the database
        insert brandNewContact;

        return brandNewContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database using the given contactId 
        List<Contact> contacts = [SELECT Id 
                                  FROM Contact
                                  WHERE Id = :contactId];

        // Takes the first Contact on the contacts list then updates its last name
        Contact contactToUpdate = contacts[0];
        contactToUpdate.LastName = newLastName;

        // Update the Contact in the database
        update contactToUpdate;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database using the given oppId
        List<Opportunity> opportunities = [SELECT Id
                                           FROM Opportunity
                                           WHERE Id = :oppId];

        // Takes the first Opportunity on the opportunities list then updates its Stage Name
        Opportunity opportunityToUpdate = opportunities[0];
        opportunityToUpdate.StageName = newStage;

        // Update the Opportunity in the database
        update opportunityToUpdate;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]
        List<Account> accounts = [SELECT Id
                                  FROM Account
                                  WHERE Id = :accountId];

        // Update the Account with the given Id with the new name and industry
        Account accountToUpdate = accounts[0];
        accountToUpdate.Name = newName;
        accountToUpdate.Industry = newIndustry;

        //Update the Account in the database
        update accountToUpdate;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for(Integer i = 0; i < opportunities.size(); i++) {
            Opportunity opportunityToUpdate = opportunities[i];
            // Set the Opportunity's Stage to Qualification
            opportunityToUpdate.StageName = 'Qualification';
            // Set the Opportunity's Close Date to 3 months from today
            opportunityToUpdate.CloseDate = date.today().addMonths(3);
            // Set the Opportunity's Amount to 50000
            opportunityToUpdate.Amount = 50000;

            // Upsert the opportunities List so that records are either updated or created
            upsert opportunities;
        }


    }

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        //Query Accounts to find the Id associated with the accountName
        List<Account> accounts = [SELECT Id
                                  FROM Account
                                  WHERE Name = :accountName
                                  LIMIT 1];
        Account account;
        
        if(accounts.isEmpty()) {
            account = new Account(Name = accountName);
            insert account;
        } else {
            account = accounts[0];
        }

        // Create a map to store existing Opportunities
        Map<String, Opportunity> existingOpportunities = new Map<String, Opportunity>();
        for (Opportunity oppty : [SELECT Id, Name
                                  FROM Opportunity
                                  WHERE AccountId = :account.Id]) {
                                  existingOpportunities.put(oppty.Name, oppty);                       
                                  }

        // Create a list to add the opportunities to upsert
        List<Opportunity> opportunitiesToUpsert = new List<Opportunity>();

        // Loop through each Opportunity name
            // Create an Opportunity with the given name and required fields
            // Add the Opportunity to the list
        for(String opportunityName : oppNames){
            if(existingOpportunities.containsKey(opportunityName)){
                Opportunity existingOppty = existingOpportunities.get(opportunityName);
                existingOppty.StageName = 'Prospecting';
                existingOppty.CloseDate = Date.today().addDays(30);
                opportunitiesToUpsert.add(existingOppty);
            } else {
                Opportunity newOpportunity = new Opportunity(Name = opportunityName,
                                                              AccountId = account.Id,
                                                              StageName = 'Prospecting',
                                                              CloseDate = Date.today().addDays(30));

            opportunitiesToUpsert.add(newOpportunity);
            }
        }
        upsert opportunitiesToUpsert;
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id 
                                  FROM Account 
                                  WHERE Name = :accountName
                                  LIMIT 1];

		// if the Account exists, update the description - else add a new Account to accounts
        if(accounts.size() > 0) {
            accounts.get(0).Description = 'Updated Account';
        } else {
            accounts.add(
                New Account(
                    Name = accountName,
                    Description = 'New Account'
                )
            );
        }

		// Upsert the accounts
        upsert accounts;

        // Return the Account that was upserted
		return accounts.get(0);
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Loop through each Contact
        for(Contact contact : contactsToUpsert){

		// Extract the Account Name from Contact's LastName
            String accountName = contact.LastName;

		// Get the account based on the name or create one if it doesn't exist using the upsertAccount method
        Account account = upsertAccount(accountName);

		// Link the Contact to its Account using the Account Id
        contact.AccountId = account.Id;
        }

		// Upsert the Contacts
        upsert contactsToUpsert;
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        
        List<Lead> leadsToInsert = new List<Lead>();

        // Loop through each Lead name
        for(String names : leadNames){
            leadsToInsert.add(new Lead(LastName = 'Nomical',
                                       Company = 'Imaginary Company'));
        }

        // Insert the Leads
        insert leadsToInsert;

        // Delete the Leads
        delete leadsToInsert;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        // Insert the cases
        for(Integer i = 0; i < numOfCases; i++) {
            Case newCase = new Case(AccountId = accountId);
            insert newCase;
        }

        // Delete the cases
        List<Case> casesToDelete = [SELECT Id
                                    FROM Case
                                    WHERE AccountId = :accountId
                                    LIMIT :numOfCases];
        
        delete casesToDelete;
    }
}