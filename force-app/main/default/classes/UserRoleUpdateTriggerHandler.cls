public class UserRoleUpdateTriggerHandler {
    public static void updateRoleNotification(Map<Id,User> oldMap, List<User> newList){
        List<Task> listOfTask = new List<Task>();
        for(User usr : newList){
            if(usr.UserRoleId!=oldMap.get(usr.Id).UserRoleId){
                if(usr.UserPermissionsSupportUser==true){
                     Task tsk = new Task();
					 tsk.Subject = 'Test Task';
					 tsk.Status = 'Open';
					 tsk.Priority = 'Normal';
					 //tsk.WhoId = usr.Id;
					 //tsk.OwnerId = null;
                    listOfTask.add(tsk);
                }else{
                     Task tsk = new Task();
					 tsk.Subject = 'Test Task';
					 tsk.Status = 'Open';
					 tsk.Priority = 'Normal';
					 //tsk.WhoId = usr.Id;
					 //tsk.OwnerId = usr.Id;
                    listOfTask.add(tsk);
                }
            }
        }
        if(!listOfTask.isEmpty() && listOfTask.size()>0){
            database.insert(listOfTask);
        }
    }
    
}