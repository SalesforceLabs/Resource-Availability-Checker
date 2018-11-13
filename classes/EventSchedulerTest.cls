@isTest
public class EventSchedulerTest {
	@isTest
    static void getEventInfoTest() {
        Event result = EventScheduler.getEventInfo(UserInfo.getUserId());
        System.assert(result == null);
        
        Event event = new Event();
        event.Subject = 'Test';
        event.StartDateTime = Datetime.now();
        event.EndDateTime = Datetime.now();
        event.OwnerId = UserInfo.getUserId();
        
        insert event;
        
        result = EventScheduler.getEventInfo(event.Id);
        System.assertEquals(event.Id, result.Id);
    }
    
    
	@isTest
    static void getAvailableUsersTest() {
        cxu_scheduler__Skill__c skill = new cxu_scheduler__Skill__c (Name = 'Test');
        insert skill;
        
        cxu_scheduler__Skill_Qualification__c qualification = new cxu_scheduler__Skill_Qualification__c();
        qualification.cxu_scheduler__User__c = UserInfo.getUserId();
        qualification.cxu_scheduler__Skill__c  = skill.Id;
        insert qualification;
        
        List<cxu_scheduler__Skill__c> skills = EventScheduler.getSkills();
        
        Event event = new Event();
        event.Subject = 'Test';
        event.StartDateTime = Datetime.newInstance(2016, 1, 1, 0, 0, 0);
        event.EndDateTime = Datetime.newInstance(2016, 1, 1, 1, 0, 0);
        event.OwnerId = UserInfo.getUserId();
        insert event;
        
        List<User> availableUsers = EventScheduler.getAvailableUsers(
            Datetime.newInstance(2016, 1, 1, 0, 30, 0), 
            Datetime.newInstance(2016, 1, 1, 1, 0, 0),
            new List<string> {skill.Id}
        );
        Set<Id> availableUserIds = new Set<Id>();
        for (User user : availableUsers) {
            availableUserIds.add(user.Id);
        }
        system.assert(!availableUserIds.contains(UserInfo.getUserId()));
    }
    
    
	@isTest
    static void assignUserToEventErrorTest() {
        string result = EventScheduler.assignUserToEvent(UserInfo.getUserId(), 
                                                         UserInfo.getUserId(),
                                                         Datetime.newInstance(2016, 1, 1, 0, 30, 0), 
                                                         Datetime.newInstance(2016, 1, 1, 0, 30, 0));
        system.assertEquals('Record is not of type "Event".', result);
    }
    
	@isTest
    static void assignUserToEventSuccessTest() {
        Event event = new Event();
        event.Subject = 'Test';
        event.StartDateTime = Datetime.newInstance(2016, 1, 1, 0, 0, 0);
        event.EndDateTime = Datetime.newInstance(2016, 1, 1, 1, 0, 0);
        event.OwnerId = UserInfo.getUserId();
        insert event;
        
        string result = EventScheduler.assignUserToEvent(UserInfo.getUserId(), 
                                                         event.Id, 
                                                         event.StartDateTime, 
                                                         event.EndDateTime);
        system.assertEquals('', result);
    }
}