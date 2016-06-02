// ------------------------------------------------------------------
// 求職者の担当を担当エリア表とルールに沿って割り当てる
//     method: setOwner はトリガから呼び出される
//     開発： uhuru
//     2016/04/26 MATCHING_PROMOTION_SYSTEM-2565 ogino
// ------------------------------------------------------------------
public class SetReqOwnerCustom {

	@TestVisible private static final String FUNCTIONCATEGORY_VALUE = '所有者変更処理';//******************************************
	//private static final String FUNCTIONCATEGORY_VALUE = '所有者----変更処理';

	//del_start_2015/11/09 ogino #7949
    //@TestVisible private static String address1Value;
	//@TestVisible private static String address2Value;
    //del_end_2015/11/09 ogino #7949

    //del_start_2015/11/09 ogino #7949
	////初期処理
	//static{

	//	try{
	//		//担当エリアが該当しない場合に送信するアドレス取得
	//		FunctionalUnitSentAddress__c addObj = [
	//			select
	//				id, Address1__c,Address2__c
	//			from
	//				FunctionalUnitSentAddress__c
	//			where
	//				name='SetReqOwnerError'
	//		];

	//		address1Value = addObj.Address1__c;
	//		address2Value = addObj.Address2__c;

	//	}catch(Exception e){

 //      		System.debug(Logginglevel.WARN, '** static exception ***'+e);
	//		//エラーの場合
	//		address1Value = 'ryosuke-imaizumi@bm-sms.co.jp';
	//	}



	//}
    //del_end_2015/11/09 ogino #7949
//add_start_2015/05/28 ogino #4915
    public static Map<Id,SObject> activeUserOrQueueMap {get;set;}
    
    public static Map<Id,SObject> getActiveUserOrQueueMap(){
        if(activeUserOrQueueMap != null){
            return activeUserOrQueueMap;
        }
        
        //有効なユーザのみ取得する
        //mod_start_2016/02/19 ogino #9695
        //List<SObject> userList = [SELECT Id,Name FROM User WHERE IsActive = true];
        List<SObject> userList = [SELECT Id,Name,UserRoleId,UserRole.Name FROM User WHERE IsActive = true];
        //mod_end_2016/02/19 ogino #9695
        
        List<SObject>  queueList = [SELECT Id, Name, DeveloperName FROM Group WHERE Type='Queue'];
        
        activeUserOrQueueMap = new Map<Id,SObject>();
        
        for(SObject sobjUser:userList){
            activeUserOrQueueMap.put((Id)sobjUser.get('Id'),sobjUser);
        }
        
        for(SObject sobjGroup:queueList){
            activeUserOrQueueMap.put((Id)sobjGroup.get('Id'),sobjGroup);
        }
        
        return activeUserOrQueueMap;
    }
    
    public static List<JobSeekerDto> errChangeOwnerJobSeekerDtoList {get;set;}
    
    public static List<JobSeekerDto> getErrChangeOwnerjobSeekerDtoList(){
        
        if(errChangeOwnerJobSeekerDtoList != null){
            return errChangeOwnerJobSeekerDtoList;
        }else{
            errChangeOwnerJobSeekerDtoList = new List<JobSeekerDto>();
        }
        
        return errChangeOwnerJobSeekerDtoList;
    }
    
    public class JobSeekerDto{
        
        //public String subject;
        
        public CustomObject1__c jobSeeker;
        
        public String debugMsg;
        
        public Boolean ownerSetFlag;
        
        public JobSeekerDto(){
            //this.subject = '';
            this.jobSeeker = new CustomObject1__c();
            this.debugMsg = '';
            this.ownerSetFlag = false;
        }
    }
//add_end_2015/05/28 ogino #4915
//add_start_2015/05/29 ogino #4915
public static Map<Id,CustomObject1__c> notMatchJobSeekerMap {get;set;}

public static Map<Id,CustomObject1__c> getNotMatchJobSeekerMap(){
    if(notMatchJobSeekerMap != null){
        return notMatchJobSeekerMap;
    }
    
    notMatchJobSeekerMap = new Map<Id,CustomObject1__c>();
    
    return notMatchJobSeekerMap;
}
//add_end_2015/05/29 ogino #4915
//add_start_2015/06/02 ogino #4915
public static Id notSendEmailGroupId {get;set;}

public static Id getNotSendEmailGroupId(){
    if(notSendEmailGroupId != null){
        return notSendEmailGroupId;
    }
    
    
    //メール送信除外キューのIdを初期化
    List<Group> notSendEmailGroupList = [Select Name, Id, DeveloperName From Group g where DeveloperName = 'notSendEmailGroup'];
    notSendEmailGroupId = notSendEmailGroupList[0].Id;
    
    return notSendEmailGroupId;
}
//add_end_2015/06/02 ogino #4915
//add_start_2015/09/25 ogino #7150
public static String S2L_ACCOUNT_ID = System.Label.S2L_ACCOUNT_ID;
//add_end_2015/09/25 ogino #7150
    // ---------------------------------------------
    // 求職者の所有者をルールにしたがってセットする （トリガから呼び出される）
    // insert時
    // ---------------------------------------------
    public static void setOwner(CustomObject1__c[] co) {

        System.debug(Logginglevel.WARN, '**************** setOwner start 11****************');

		//2014/8/25 daidouzi delete start #3276
		/*
		//共通処理//2013/12/19 daidouzi mod  #2193 #2194
    	//setOwnerRun(co);

		//2014/7/30 daidouzi add start #3129
		//新ロジック対応フラグ
		Boolean newAllocationLogicCustom = false;
		try{
			newAllocationLogicCustom = OrganizationSettings__c.getOrgDefaults().NewAllocationLogicCustom__c;
		}catch(NullPointerException e){
			System.debug(Logginglevel.WARN, '----:'+e);
		}

		if(newAllocationLogicCustom){
			//修正版
    		setOwnerRunCustom(co);

		}else{

			//既存のロジック
			setOwnerRun(co);

		}
		//2014/7/30 daidouzi add end #3129
		*/
		//2014/8/25 daidouzi delte end #3276

		//共通処理。修正版
		//setOwnerRunCustom(co); //2014/8/25 daidouzi add #3276

    	//---------------------------------------------
    	//求職者ID取得CCから所有者を設定する。
    	//設定されない求職者は担当エリア表から所有者を設定する
    	//---------------------------------------------
		//所有者変更されなかったリスト
		List<CustomObject1__c> unsetList;

    	//求職者ID取得CCから所有者を設定する
    	//unsetList = setOwnerForKyusyokuId(co);

    	//担当エリアj表以外のルールで所有者を設定する
    	unsetList = setOwnerForSpecial(co);

        System.debug(Logginglevel.WARN, '-------所有者変更されなかったリスト:'+unsetList.size());

		//対象の求職者がいる場合
		if(unsetList.size() > 0){

	    	//---------------------------------------------
	    	//共通処理。担当エリア表から所有者を設定する
	    	//---------------------------------------------
			setOwnerRunCustom(co);

		}

        System.debug(Logginglevel.WARN, '**************** setOwner end 11****************');
        //add_start_2016/02/19 ogino #9695
        buildEntryAllocation(co);
        //add_end_2016/02/19 ogino #9695
		
    }
    
    /**
     * 60日以内の場合の掘り起こし、所有者変更
     * WEBサイトの判別をして、求職者に対して所有者のセットを行う
     * update時に呼び出しされる。
     */
    public static void setOwnerWithin60day(CustomObject1__c[] co, Map<id, CustomObject1__c> coOldMap) {
    	system.debug(' *** 60日以内掘起こしの所有者変更(RJB) ***');
    	system.debug(' *** CustomObject1__c[]  co *** : ' + co);
    	
    	//取得対象のキューのapi名
        Set<String> queueNames = new Set<String>();
        queueNames.add('RJB_student');     //RJB学生専用

        //キューを取得する
        List<Group> groupList = [SELECT Id, Name, DeveloperName FROM Group WHERE Type='Queue' and DeveloperName =: queueNames];

        Map<String, Group> gropuMenberMap = new Map<String, Group>();

        //対象のキューが取得できない場合はどうする？⇒特定の人にメールする仕組みを実装
        for(Group gObj: groupList){
            gropuMenberMap.put(gObj.DeveloperName , gObj);
        }

        //所有者が変更されていない求職者を保持する
        List<CustomObject1__c> unsetList = new List<CustomObject1__c>();

        //所有者が変更された求職者を保持する
        List<CustomObject1__c> settingList = new List<CustomObject1__c>();

        //エラーが発生した求職者を保持する
        List<CustomObject1__c> errorList = new List<CustomObject1__c>();
    	
    		
		for( CustomObject1__c kyusokusha: co){
			String site = distributesSite(kyusokusha);
			Boolean ownerSetflag = false;
			CustomObject1__c customerOld = coOldMap.get(kyusokusha.Id); 
			
			system.debug('***customerOld.Field14__c : ' + customerOld.Field14__c + ' *** kyusokusha.Field14__c  ' + kyusokusha.Field14__c);
			
		    if(site == 'PTOTJB'){
		    	//所有者の割り振りを行う。
		    	if(kyusokusha.Field14__c.indexOf('学生') != -1){
		    		//保有資格に学生が含まれている場合は学生専用キューに割り振る
		    		if(    gropuMenberMap != null && gropuMenberMap.get('RJB_student') != null
                        && getActiveUserOrQueueMap().get(gropuMenberMap.get('RJB_student').id) != null){
                        
                        //RJB学生専用キュー設定
                        System.debug(Logginglevel.WARN, '********* ケアリハ:RJB学生自動振り分けの場合');
                        ownerSetflag = true;
                        //所有者をに変f更する。RJB学生専用
                        kyusokusha.OwnerId = gropuMenberMap.get('RJB_student').id;
                    }
		    	}else if(customerOld.Field14__c.indexOf('学生') != -1 && kyusokusha.Field14__c.indexOf('学生') == -1){
		    		//過去に学生で、掘起こし時は学生でない求職者に対して所有者設定を行う
                    system.debug(' --- 過去に学生で、掘起こし時は学生でない求職者に対して所有者設定を行う --- ');
		    		//担当エリア表に基づいて所有者を設定する
		    		if(!ownerSetflag){
		    			system.debug(' *** 担当エリア表に基づいて所有者の変更を行う ***');
                        //所有者を設定する
                        setOwnerRunCustom(co);
		    			
		    			ownerSetflag = true;
		    		}
		    	}
		    	
		    }	
		}
    	
    }
    

    // ---------------------------------------------
    // 求職者の所有者をルールにしたがってセットする （トリガから呼ばれるハンドラーから呼び出される）
    // 変更前の値を使用するパターン。
    //   ⇒変更前の値を使用しない
    // update時に呼ばれる
    // ---------------------------------------------
    public static void setOwner(CustomObject1__c[] co, Map<id, CustomObject1__c> coOldMap) {

        System.debug(Logginglevel.WARN, '**************** setOwner start 22****************');

		//共通処理//2013/12/19 daidouzi mod  #2193 #2194
    	//setOwner(co); //setOwnerで求職者Id取得CCから所有者を設定しているため同じ処理を通るためコメントアウト。代わりにsetOwnerRunCustomを呼ぶ

    	//---------------------------------------------
    	//求職者ID取得CCとactionから所有者を設定する。
    	//設定されない求職者は担当エリア表から所有者を設定する
    	//---------------------------------------------
		//所有者変更されなかったリスト
		List<CustomObject1__c> unsetList;

    	//求職者ID取得CCとactionから所有者を設定する
    	//unsetList = setOwnerForKyusyokuIdAndAction(co ,coOldMap);
    	unsetList = setOwnerForSpecial(co ,coOldMap);

        System.debug(Logginglevel.WARN, '-------所有者変更されなかったリスト:'+unsetList.size());


		//対象の求職者がいる場合
		if(unsetList.size() > 0){

	    	//---------------------------------------------
	    	//共通処理。担当エリア表から所有者を設定する
	    	//---------------------------------------------
			setOwnerRunCustom(co);

		}

        System.debug(Logginglevel.WARN, '**************** setOwner end 22****************');
        //add_start_2016/02/19 ogino #9695
        buildEntryAllocation(co);
        //add_end_2016/02/19 ogino #9695
    }

	/**
	 * 引数1つから2つのを呼び出す         //2015/3/2 daidouzi add  #4634
	 */
    public static List<CustomObject1__c> setOwnerForSpecial(CustomObject1__c[] co) {
        System.debug(Logginglevel.WARN, '-------setOwnerForSpecial---引数1--');
   		return setOwnerForSpecial(co, null);
    }

    /**
     * 求職者ID取得CCとactionから所有者を設定する
     * WFで設定していた、項目自動更新の処理も行う
     * insert/update時に通る処理
     * 2015/3/2 daidouzi add start #4634
     *
     * @return 所有者を設定していない求職者リスト
     */
    public static List<CustomObject1__c> setOwnerForSpecial(CustomObject1__c[] co, Map<id, CustomObject1__c> coOldMap) {
        System.debug(Logginglevel.WARN, '-------setOwnerForSpecial---引数2--');

    	//ユーザとキューを取得
        System.debug(Logginglevel.WARN, '-------setOwnerForSpecial:'+co.size());

		/*         //2015/3/2 daidouzi delete #4634

		//RJB学生専用を取得する
        List<Group> rjbGkusei = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'RJB_student'];

        //看護学生用キュー、商品設計チーム取得
        List<Group> kgGoup = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'ProductDesignTeam'];

        //希望職種：その他自動振り分け（単独選択時）、山田 宏行アカウント取得
        List<Group> hopeCateGroup = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'HopeJobCategoryOtherGroup'];

		//キューを取得する
		//2014/8/1 daidouzi mod start #3206
        //List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and Name = '上京・帰国ナース'];
        List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'DeveloperName20130318'];
		//2014/8/1 daidouzi mod end #3206

		//2014/12/05 daidouzi add start #4248
		//ソリューション登録を取得する
        List<Group> Group_solQue = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'Group_sol'];
		//2014/12/05 daidouzi add end #4248

		//メディア企画求職者IDキューを取得する
        List<Group> mpIdQue = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'mp_id_que'];
        */

		//取得対象のキューのapi名
		Set<String> queueNames = new Set<String>();
		queueNames.add('RJB_student');     //RJB学生専用
		queueNames.add('ProductDesignTeam');     //看護学生用キュー、商品設計チーム
		queueNames.add('HopeJobCategoryOtherGroup');     //希望職種：その他自動振り分け（単独選択時）
		queueNames.add('DeveloperName20130318');     //上京・帰国ナース
		queueNames.add('Group_sol');     //ソリューション登録
		queueNames.add('mp_id_que');     //メディア企画求職者IDキュー

		//キューを取得する
        List<Group> groupList = [SELECT Id, Name, DeveloperName FROM Group WHERE Type='Queue' and DeveloperName =: queueNames];

        Map<String, Group> gropuMenberMap = new Map<String, Group>();

        //対象のキューが取得できない場合はどうする？⇒特定の人にメールする仕組みを実装
        for(Group gObj: groupList){
        	gropuMenberMap.put(gObj.DeveloperName , gObj);
        }

        System.debug(Logginglevel.WARN, '-------gropuMenberMap:'+gropuMenberMap);
        System.debug(Logginglevel.WARN, '-------co.size():'+co.size());

		//所有者が変更されていない求職者を保持する-------------------------------------------------------------
		List<CustomObject1__c> unsetList = new List<CustomObject1__c>();

		//所有者が変更された求職者を保持する-------------------------------------------------------------
		List<CustomObject1__c> settingList = new List<CustomObject1__c>();

		//エラーが発生した求職者を保持する-------------------------------------------------------------
		List<CustomObject1__c> errorList = new List<CustomObject1__c>();

		for( CustomObject1__c kyusokusha: co){

			//所有者を設定したら、ほかの所有者設定ロジックは処理しない。
			//所有者を変更した場合trueになる。
			Boolean ownerSetflag = false;
			//add_start_2015/05/29 ogino #4915
			String debugMsg = '\r\nシステム情報：\r\n';
			//add_end_2015/05/29 ogino #4915

			//【テスト】を含む場合は処理しない
            if(kyusokusha.Name == null || !kyusokusha.Name.startsWith('【テスト】')){

                System.debug(Logginglevel.WARN, '-------kyusokusha.CC_form_cc_name__c:'+kyusokusha.CC_form_user_id__c);

                try{

	                //----------------------------------------------------------
	                //ケアリハ:RJB学生自動振り分け WFから寄せた処理
	                //----------------------------------------------------------
					// 希望職種から登録サイトを決定
	            	String site = distributesSite(kyusokusha);
		            if(site == 'PTOTJB'
		            	//&& kyusokusha.Field14__c =='学生' //mod tokashiki 2016/01/04 (SYSTEM_CO_MEDICAL-2068)
		            	&& kyusokusha.Field14__c.indexOf('学生') != -1
		            ){
		                //mod_start_2015/05/28 ogino #4915
		            	//RJB学生専用キュー設定
			        	//System.debug(Logginglevel.WARN, '********* ケアリハ:RJB学生自動振り分けの場合');
	                    //ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
		        		//所有者をに変更する。RJB学生専用
		        		//kyusokusha.OwnerId = gropuMenberMap.get('RJB_student').id;
		        		if(gropuMenberMap != null && gropuMenberMap.get('RJB_student') != null
		        		        && getActiveUserOrQueueMap().get(gropuMenberMap.get('RJB_student').id) != null){
		        		    
                            //RJB学生専用キュー設定
                            System.debug(Logginglevel.WARN, '********* ケアリハ:RJB学生自動振り分けの場合');
                            ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
                            //所有者をに変更する。RJB学生専用
                            kyusokusha.OwnerId = gropuMenberMap.get('RJB_student').id;
		        		    
		        		}else{
		        		    //String subject = 'IDが不正なため、所有者を変更できませんでした（RJB_student）';
		        		    //JobSeekerDto jobSeekerDto = new JobSeekerDto();
		        		    //jobSeekerDto.subject = subject;
		        		    //jobSeekerDto.jobSeeker = kyusokusha;
		        		    //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
		        		    debugMsg += 'RJB_student\r\n';
		        		}
		        		//mod_end_2015/05/28 ogino #4915
		            }

	                //----------------------------------------------------------
	                //求職者ID取得CC
	                //メディア企画求職者ID
	                //----------------------------------------------------------
	                if(!ownerSetflag){
                        //add_start_2015/08/07 ogino #6645
                        //更新前の、求職者を取得する
                        CustomObject1__c kyusokushaOld = null;
                        if(coOldMap != null){
                            kyusokushaOld = coOldMap.get(kyusokusha.id);
                        }
                        //add_end_2015/08/07 ogino #6645

		                //求職者ID取得CC（ユーザーＩＤ)が入力されている場合
		                //mod_start_2015/05/28 ogino #4915
		                //if(kyusokusha.CC_form_user_id__c != null && kyusokusha.CC_form_user_id__c != ''){

		                //    //所有者に求職者ID取得CC（ユーザーＩＤ)を設定する
		                //    kyusokusha.OwnerId = kyusokusha.CC_form_user_id__c;
		                //    ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634

		                //    System.debug(Logginglevel.WARN, '-------求職者ID取得CC（ユーザーＩＤ)が入力されている場合:'+kyusokusha.OwnerId);
		                //}
                        if(kyusokusha.CC_form_user_id__c != null && kyusokusha.CC_form_user_id__c != ''
                                && getActiveUserOrQueueMap().get(kyusokusha.CC_form_user_id__c) != null){

                            //所有者に求職者ID取得CC（ユーザーＩＤ)を設定する
                            kyusokusha.OwnerId = kyusokusha.CC_form_user_id__c;
                            ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
                            //add_start_2015/08/07 ogino #6645
                            if(kyusokushaOld == null){
                                if(String.isNotBlank(kyusokusha.action__c)){
                                    if(kyusokusha.action__c.lastIndexOf('_moshimoshi')>-1){
                                        kyusokusha.CC_form_cc_name__c = null;
                                        kyusokusha.tmp_text3__c = null;
                                    }
                                }
                                if(String.isNotBlank(kyusokusha.action2__c)){
                                    if(kyusokusha.action2__c.lastIndexOf('_moshimoshi')>-1){
                                        kyusokusha.CC_form_cc_name__c = null;
                                        kyusokusha.tmp_text3__c = null;
                                    }
                                }
                            }
                            //add_end_2015/08/07 ogino #6645

                            System.debug(Logginglevel.WARN, '-------求職者ID取得CC（ユーザーＩＤ)が入力されている場合:'+kyusokusha.OwnerId);
                        }else{
                            //String subject = 'IDが不正なため、所有者を変更できませんでした（CC_form_user_id__c）';
                            //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                            //jobSeekerDto.subject = subject;
                            //jobSeekerDto.jobSeeker = kyusokusha;
                            //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                            debugMsg += 'CC_form_user_id__c\r\n';
                        }
                        //mod_end_2015/05/28 ogino #4915

		                //2014/7/30 daidouzi add start #3179
		                //action or action2 にsms_idが設定されている場合は、所有者をキュー（メディア企画求職者ID）に変更
		                //mod_start_2015/05/28 ogino #4915
                        //del_start_2015/09/29 ogino #7160
                        /*
		            	//if(kyusokusha.action__c != null
		            	//	&& kyusokusha.action__c.indexOf('sms_id_mp') != -1
		            	//){
		            		//メディア企画求職者IDを設定する
		        		//	kyusokusha.OwnerId = gropuMenberMap.get('mp_id_que').id;
		                //   	ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
		                //   	System.debug(Logginglevel.WARN, '--action__cにsms_id_mp一致している--');
		            	//}
                        if(kyusokusha.action__c != null
                          && kyusokusha.action__c.indexOf('sms_id_mp') != -1
                          && gropuMenberMap.get('mp_id_que') != null
                          && getActiveUserOrQueueMap().get(gropuMenberMap.get('mp_id_que').id) != null
                        ){
                            //メディア企画求職者IDを設定する
                          kyusokusha.OwnerId = gropuMenberMap.get('mp_id_que').id;
                              ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
                              System.debug(Logginglevel.WARN, '--action__cにsms_id_mp一致している--');
                        }else{
                            //String subject = 'IDが不正なため、所有者を変更できませんでした（action,mp_id_que）';
                            //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                            //jobSeekerDto.subject = subject;
                            //jobSeekerDto.jobSeeker = kyusokusha;
                            //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                            debugMsg += 'action,mp_id_que\r\n';
                        }

		            	//if(kyusokusha.action2__c != null
		            	//	&& kyusokusha.action2__c.indexOf('sms_id_mp') != -1
		            	//){
							//メディア企画求職者IDを設定する
						//	kyusokusha.OwnerId = gropuMenberMap.get('mp_id_que').id;
						//	ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
						//	System.debug(Logginglevel.WARN, '--action2__cにsms_id_mp一致している--');
		            	//}
                        if(kyusokusha.action2__c != null
                            && kyusokusha.action2__c.indexOf('sms_id_mp') != -1
                            && gropuMenberMap.get('mp_id_que') != null
                            && getActiveUserOrQueueMap().get(gropuMenberMap.get('mp_id_que').id) != null
                        ){
                            //メディア企画求職者IDを設定する
                            kyusokusha.OwnerId = gropuMenberMap.get('mp_id_que').id;
                            ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
                            System.debug(Logginglevel.WARN, '--action2__cにsms_id_mp一致している--');
                        }else{
                            //String subject = 'IDが不正なため、所有者を変更できませんでした（action2,mp_id_que）';
                            //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                            //jobSeekerDto.subject = subject;
                            //jobSeekerDto.jobSeeker = kyusokusha;
                            //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                            debugMsg += 'action2,mp_id_que\r\n';
                        }
                        */
                        //del_end_2015/09/29 ogino #7160
                        //mod_end_2015/05/28 ogino #4915
		                //2014/7/30 daidouzi add end #3179
	                }

	                //----------------------------------------------------------
	                //【(NJB)上京・帰国ナース(ワールドアベニュー)】所有者変更2
	                //Sol経由の登録者をSOLユーザに割振る WFから寄せた処理 v//2015/3/2 daidouzi add start #4634
	                //---------------------------------------------------------- //2015/3/2 daidouzi add start #4634
	                if(!ownerSetflag){

						//更新前の、求職者を取得する
		                CustomObject1__c kyusokushaOld = null;
		                if(coOldMap != null){
		                	coOldMap.get(kyusokusha.id);
		                }

		                //更新前のレコードは使用しない。oldは使わずnewを使う
		                kyusokushaOld = kyusokusha; //2015/3/2 daidouzi add #4634

		                System.debug(Logginglevel.WARN, '-------kyusokushaOld:'+kyusokushaOld);

		                //更新前の求職者がある場合
		                //新規の場合、action__cとaction2__cによって所有者を変更するロジックはWFにて実装している。
		                if(kyusokushaOld != null){

							/* 2014/8/20 daidouzi delete #3274
		                	//上京案件がtrueの場合
		                	if(kyusokushaOld.Field435__c == true){
		                		//キューを設定する
		                   		kyusokusha.OwnerId = queueList[0].id;
		                   		System.debug(Logginglevel.WARN, '--上京案件がtrue--');
		                	}
		                	*/

		                	//【(NJB)上京・帰国ナース(ワールドアベニュー)】
		                	//action__cに"pchp_worldavenue" or "sphp_worldavenue"一致している値が入っている場合
		                	//mod_start_2015/05/28 ogino
		                	//if(kyusokushaOld.action__c != null
		                	//	&& (
		                	//		kyusokushaOld.action__c.indexOf('pchp_worldavenue') != -1
		                	//		|| kyusokushaOld.action__c.indexOf('sphp_worldavenue') != -1
		                	//	)
		                	//){
		                   	//	System.debug(Logginglevel.WARN, '--action__cにpchp_worldavenue or sphp_worldavenue一致している--');
		                	//	//キューを設定する
		                   	//	//kyusokusha.OwnerId = queueList[0].id;
		                   	//	kyusokusha.OwnerId = gropuMenberMap.get('DeveloperName20130318').id;
		                   	//	ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
		                	//}
                            if(kyusokushaOld.action__c != null
                                && (
                                    kyusokushaOld.action__c.indexOf('pchp_worldavenue') != -1
                                    || kyusokushaOld.action__c.indexOf('sphp_worldavenue') != -1
                                )
                                && gropuMenberMap.get('DeveloperName20130318') != null
                                && getActiveUserOrQueueMap().get(gropuMenberMap.get('DeveloperName20130318').id) != null
                            ){
                                System.debug(Logginglevel.WARN, '--action__cにpchp_worldavenue or sphp_worldavenue一致している--');
                                //キューを設定する
                                //kyusokusha.OwnerId = queueList[0].id;
                                kyusokusha.OwnerId = gropuMenberMap.get('DeveloperName20130318').id;
                                ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
                            }else{
                                //String subject = 'IDが不正なため、所有者を変更できませんでした（action,DeveloperName20130318）';
                                //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                                //jobSeekerDto.subject = subject;
                                //jobSeekerDto.jobSeeker = kyusokusha;
                                //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                                debugMsg += 'action,DeveloperName20130318\r\n';
                            }

		                	//【(NJB)上京・帰国ナース(ワールドアベニュー)】
		                	//action2__cに"pchp_worldavenue" or "sphp_worldavenue"一致している値が入っている場合
		                	//if(kyusokushaOld.action2__c != null
		                	//	&& (
		                	//		kyusokushaOld.action2__c.indexOf('pchp_worldavenue') != -1
		                	//		|| kyusokushaOld.action2__c.indexOf('sphp_worldavenue') != -1
		                	//	)
		                	//){
		                   	//	System.debug(Logginglevel.WARN, '--action2__cにpchp_worldavenue or sphp_worldavenue一致している--');
		                	//	//キューを設定する
		                   	//	//kyusokusha.OwnerId = queueList[0].id;
		                   	//	kyusokusha.OwnerId = gropuMenberMap.get('DeveloperName20130318').id;
		                   	//	ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
		                	//}
                            if(kyusokushaOld.action2__c != null
                                && (
                                    kyusokushaOld.action2__c.indexOf('pchp_worldavenue') != -1
                                    || kyusokushaOld.action2__c.indexOf('sphp_worldavenue') != -1
                                )
                                && gropuMenberMap.get('DeveloperName20130318') != null
                                && getActiveUserOrQueueMap().get(gropuMenberMap.get('DeveloperName20130318').id) != null
                            ){
                                System.debug(Logginglevel.WARN, '--action2__cにpchp_worldavenue or sphp_worldavenue一致している--');
                                //キューを設定する
                                //kyusokusha.OwnerId = queueList[0].id;
                                kyusokusha.OwnerId = gropuMenberMap.get('DeveloperName20130318').id;
                                ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
                            }else{
                                //String subject = 'IDが不正なため、所有者を変更できませんでした（action2,DeveloperName20130318）';
                                //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                                //jobSeekerDto.subject = subject;
                                //jobSeekerDto.jobSeeker = kyusokusha;
                                //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                                debugMsg += 'action2,DeveloperName20130318\r\n';
                            }

							//2014/12/05 daidouzi add start #4248 //
							//Sol経由の登録者をSOLユーザに割振る WFから寄せた処理
		                	//if(kyusokushaOld.action__c != null
		                	//	&& kyusokushaOld.action__c.indexOf('from_sol') != -1
		                	//){
		                   	//	System.debug(Logginglevel.WARN, '--action__cにfrom_sol一致している--');

		                	//	//「ソリューション登録」キューに割当てる
		                   	//	//kyusokusha.OwnerId = Group_solQue[0].id;
		        			//	kyusokusha.OwnerId = gropuMenberMap.get('Group_sol').id;
		                   	//	ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
		                	//}
                            if(kyusokushaOld.action__c != null
                                && kyusokushaOld.action__c.indexOf('from_sol') != -1
                                && gropuMenberMap.get('Group_sol') != null
                                && getActiveUserOrQueueMap().get(gropuMenberMap.get('Group_sol').id) != null
                            ){
                                System.debug(Logginglevel.WARN, '--action__cにfrom_sol一致している--');

                                //「ソリューション登録」キューに割当てる
                                //kyusokusha.OwnerId = Group_solQue[0].id;
                                kyusokusha.OwnerId = gropuMenberMap.get('Group_sol').id;
                                ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
                            }else{
                                //String subject = 'IDが不正なため、所有者を変更できませんでした（Group_sol）';
                                //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                                //jobSeekerDto.subject = subject;
                                //jobSeekerDto.jobSeeker = kyusokusha;
                                //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                                debugMsg += 'Group_sol\r\n';
                            }
                            //mod_end_2015/05/28 ogino #4915
		                	//2014/12/05 daidouzi add end #4248
		                }
	                }


	                //----------------------------------------------------------
	                //看護学生自動振り分け WFから寄せた処理         //2015/3/2 daidouzi add start #4634
	                //----------------------------------------------------------
	                if(!ownerSetflag){

			        	//★保有資格が看護学生と一致の場合
			        	//mod_start_2015/05/28 ogino
				        //if (kyusokusha.Field14__c == '看護学生') {

				        //	System.debug(Logginglevel.WARN, '********* ★保有資格が看護学生と一致');
			        	//	kyusokusha.DeliveryFlag__c = false;
		                //    ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
			        	//	//所有者をに変更する。商品設計チーム共通アカウント
	        			//	kyusokusha.OwnerId = gropuMenberMap.get('ProductDesignTeam').id;


				        //}
                        if (kyusokusha.Field14__c == '看護学生'
                                && gropuMenberMap.get('ProductDesignTeam') != null
                                && getActiveUserOrQueueMap().get(gropuMenberMap.get('ProductDesignTeam').id) != null) {

                            System.debug(Logginglevel.WARN, '********* ★保有資格が看護学生と一致');
                            kyusokusha.DeliveryFlag__c = false;
                            ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
                            //所有者をに変更する。商品設計チーム共通アカウント
                            kyusokusha.OwnerId = gropuMenberMap.get('ProductDesignTeam').id;


                        }else{
                            //String subject = 'IDが不正なため、所有者を変更できませんでした（ProductDesignTeam）';
                            //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                            //jobSeekerDto.subject = subject;
                            //jobSeekerDto.jobSeeker = kyusokusha;
                            //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                            debugMsg += 'ProductDesignTeam\r\n';
                        }
                        //mod_end_2015/05/28 ogino #4915
	                }

	                //----------------------------------------------------------
	                //希望職種：その他自動振り分け（単独選択時）WFから寄せた処理 //2015/3/2 daidouzi add start #4634
	                //----------------------------------------------------------
	                if(!ownerSetflag){

				        	System.debug(Logginglevel.WARN, '****kyusokusha.nj_id__c'+kyusokusha.nj_id__c);
				        	System.debug(Logginglevel.WARN, '****kyusokusha.Field16'+kyusokusha.Field16__c);
				        	System.debug(Logginglevel.WARN, '****kyusokusha.Field144__c'+kyusokusha.Field144__c);
				        	System.debug(Logginglevel.WARN, '****kyusokusha.Field14__c'+kyusokusha.Field14__c);

				        //希望職種：その他自動振り分け（単独選択時）の場合
				        //mod_start_2015/05/28 ogino #4915
				        //if(kyusokusha.nj_id__c != null
				        //	&& kyusokusha.Field16__c == 'その他'
				        //	&& (kyusokusha.Field144__c == 'NJB'
				        //		|| kyusokusha.Field144__c == 'M_NJB'
				        //	)
				        //){
				        //	System.debug(Logginglevel.WARN, '********* 希望職種：その他自動振り分け（単独選択時）の場合');
		                //    ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
			        	//	//所有者をに変更する。 その他自動振分用キュー
			        	//	kyusokusha.OwnerId = gropuMenberMap.get('HopeJobCategoryOtherGroup').id;

				        //}
                        if(kyusokusha.nj_id__c != null
                            && kyusokusha.Field16__c == 'その他'
                            && (kyusokusha.Field144__c == 'NJB'
                                || kyusokusha.Field144__c == 'M_NJB'
                            )
                            && gropuMenberMap.get('HopeJobCategoryOtherGroup') != null
                            && getActiveUserOrQueueMap().get(gropuMenberMap.get('HopeJobCategoryOtherGroup').id) != null
                        ){
                            System.debug(Logginglevel.WARN, '********* 希望職種：その他自動振り分け（単独選択時）の場合');
                            ownerSetflag = true; //----------------------------//2015/3/2 daidouzi add #4634
                            //所有者をに変更する。 その他自動振分用キュー
                            kyusokusha.OwnerId = gropuMenberMap.get('HopeJobCategoryOtherGroup').id;

                        }else{
                            //String subject = 'IDが不正なため、所有者を変更できませんでした（HopeJobCategoryOtherGroup）';
                            //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                            //jobSeekerDto.subject = subject;
                            //jobSeekerDto.jobSeeker = kyusokusha;
                            //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                            debugMsg += 'HopeJobCategoryOtherGroup\r\n';
                        }
                        //mod_end_2015/05/28 ogino #4915
	                }

		            //所有者を設定しない場合。テスト含むレコードは対象外
		            if(!ownerSetflag){
		            	//未処理Mapに設定
		            	unsetList.add(kyusokusha);
		            	System.debug(Logginglevel.WARN, '********* 所有者を設定しない場合');

		            //所有者が設定された場合
		            }else{
		            	System.debug(Logginglevel.WARN, '********* 所有者が設定された場合');
		            	settingList.add(kyusokusha);
		            }
                    //add_start_2015/05/29 ogino #4915
                    JobSeekerDto jobSeekerDto = new JobSeekerDto();
                    jobSeekerDto.ownerSetFlag = ownerSetflag;
                    jobSeekerDto.debugMsg = debugMsg;
                    jobSeekerDto.jobSeeker = kyusokusha;
                    getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                    //add_end_2015/05/29 ogino #4915

                }catch(Exception e){
                	//設定するキュがない場合などにキャッチする。
		            System.debug(Logginglevel.WARN, '********* エラーの場合'+ e.getMessage() );
		            System.debug(Logginglevel.WARN, '***'+ e.getStackTraceString() );

                	//エラー用につめる
                	errorList.add(kyusokusha);

                }

            }
        }

        //メール送信
        //2015/3/2 daidouzi add start #4634
		//割り振り処理。所有者が設定された求職者の所有者にメール送信するため、ユーザを取得する
		Map<String, List<User>> userListMap = getUserForOwnerId(settingList);
		//afterで処理するため退避
		Utility.setUserListForAllocation(userListMap);

        System.debug( '********* 割り振り処理。所有者が設定された求職者の所有者にメール送信 対象数＝'+userListMap);

		//エラーが発生した求職者にたいして特定の人にメールでアラートを飛ばす
   		//エラーが発生した求職者情報を退避するafterで処理するため
		Utility.setUserListForAllocationErroe(errorList);

        System.debug(Logginglevel.WARN, '********* 割り振り処理。エラーが発生した求職者にたいして特定の人にメールでアラートを飛ばす 対象数＝'+errorList.size());

        //2015/3/2 daidouzi add end #4634

        return unsetList;

    }

	/**
	 * 共通の処理
	 *
	 * setOwnerRunの修正版、いずれこちらを使用する方針
	 *    ⇒使っている。様子を見て作成元のメソッドを削除する。
	 *
	 *
     * setOwner(CustomObject1__c[] co) から呼ばれる
     * setOwner(CustomObject1__c[] co, Map<id, CustomObject1__c> coOldMap)からから呼ばれる
	 */
    public static void setOwnerRunCustom(CustomObject1__c[] co) {

		System.debug( '>>>>>> setOwnerRunCustom start');

		//登録サイト
        String site;

        ///常勤、非常勤
        String timeType;
        //
        Boolean found = false;

        //住所が一致した求職者
        Map<String,CustomObject1__c> addMatchKyusyokusyaMap = new Map<String,CustomObject1__c>();

        //住所が一致していない求職者
        Map<String,CustomObject1__c> addNotMatchKyusyokusyaMap = new Map<String,CustomObject1__c>();

        //住所が一致していない求職者
        List<CustomObject1__c> lastAddNotMatchKyusyokusyaList = new List<CustomObject1__c>();

        //一致した担当エリア  求職者id=>担当エリア
        Map<String ,CustomObject3__c> matchTantouAreaMap = new Map<String ,CustomObject3__c>();


		// ----------------------------------------------------------------------------
        //担当エリア表と一致する住所を持つ求職者を絞り込む パターン1、2
        //メソッド内で、Mapに必要な情報をつめる
		// ----------------------------------------------------------------------------
    	searchMatcheAddress(
	    	co
	    	,addMatchKyusyokusyaMap
	    	,addNotMatchKyusyokusyaMap
	    	,matchTantouAreaMap
 	   	);

        System.debug(Logginglevel.WARN, '--------addNotMatchKyusyokusyaMap.values.size()'+addNotMatchKyusyokusyaMap.values().size());
        System.debug(Logginglevel.WARN, '--------パターン1,2に住所一致しない求職者');


		// ----------------------------------------------------------------------------
        //担当エリア表と一致する住所を持つ求職者を絞り込む パターン3、4
		//パターン1,2に住所一致しない求職者
        //メソッド内で、Mapに必要な情報をつめる
		// ----------------------------------------------------------------------------
		searchMatcheAddressSecond(
	    	addMatchKyusyokusyaMap
	    	,addNotMatchKyusyokusyaMap
	    	,matchTantouAreaMap
    		,lastAddNotMatchKyusyokusyaList
 		);

   		//どこにも一致しない求職者について、特定の担当者にメールでアラートを飛ばす
   		//エラーが発生した求職者情報を退避するafterで処理するため
		Utility.setUserListForTantouAreaError(lastAddNotMatchKyusyokusyaList);
		System.debug(Logginglevel.WARN, '**どこにも一致しない求職者について、特定の担当者にメールでアラートを飛ばす**'+lastAddNotMatchKyusyokusyaList.size());

		// ----------------------------------------------------------------------------
		//パターン+転職希望時期を元に割り当て表を取得
        //担当エリア表と一致する住所を持つ求職者の所有者を更新
		// ----------------------------------------------------------------------------
		System.debug(Logginglevel.WARN, '**求職者と一致した担当エリアから割り当て表を取得する**');
		System.debug(Logginglevel.WARN, '**担当エリア表数=' + matchTantouAreaMap.size());
		System.debug(Logginglevel.WARN, '**求職者数=' + addMatchKyusyokusyaMap.size());

		//パターン+転職希望時期を元に割り当て表を取得
		processAllocation(matchTantouAreaMap, addMatchKyusyokusyaMap);

    }
//add_start_2016/02/19 ogino #9695
    public static void buildEntryAllocation(List<CustomObject1__c> jobSeekerList){
        for(CustomObject1__c objJobSeeker:jobSeekerList){
            SObject objOwner = getActiveUserOrQueueMap().get(objJobSeeker.OwnerId);
            String strOwnerId = (String)objJobSeeker.OwnerId;
            if(objOwner == null){
                continue;
            }

            if(strOwnerId.substring(0,3) == '005'){
                if((String)objOwner.get('UserRoleId') != null){
                    UserRole objUserRole = (UserRole)objOwner.getSObject('UserRole');
                    objJobSeeker.entry_allocation__c = objUserRole.Name;
                }else{
                    objJobSeeker.entry_allocation__c = '';
                }
            }
            if(strOwnerId.substring(0,3) == '00G'){
                objJobSeeker.entry_allocation__c = (String)objOwner.get('Name');
            }
            //add_start_2016/03/23 ogino #10632
            if(
                objJobSeeker.entry_allocation__c == 'メディア企画部（FCC）'
            ){
                objJobSeeker.FCC_entry_allocation_owner__c = (String)objOwner.get('Name');
            }
            //add_end_2016/03/23 ogino #10632
        }
    }
//add_end_2016/02/19 ogino #9695
	/**
	 * 登録連携ユーザor康祐さんに割り振り。メールでアラートを飛ばす
	 *
	 */
	public static void sendMailForNotMatch(List<CustomObject1__c> targetList){

		System.debug(Logginglevel.WARN, '**特定の担当者にメールでアラートを飛ばす ' + targetList.size());

		//送信メール
		List<SendMail__c> sendmailList = new List<SendMail__c>();

   		//登録連携ユーザor康祐さんに割り振り。メールでアラートを飛ばす
   		for(CustomObject1__c kyusyokusya: targetList){
            // 住所を求める （PCと携帯で異なる）
            String addr = kyusyokusya.Field6__c;  // 都道府県

            //市区町村が空の場合
            if (kyusyokusya.Field7__c == null) {  // 携帯から手入力されたか？
                addr += kyusyokusya.Field21__c;   // + yes: 住所詳細（市区町村以下）を追加
            } else {
                addr += kyusyokusya.Field7__c;    // + no: 市区町村を追加
            }

            //メール送信オブジェクト生成する
            SendMail__c mail = createSendMailForNotMatch(kyusyokusya, addr);

            sendmailList.add(mail);
            
            //add_start_2015/05/29 ogino #4915
            getNotMatchJobSeekerMap().put(kyusyokusya.Id,kyusyokusya);
            //add_end_2015/05/29 ogino #4915

   		}

		//一致しない求職者情報をメールする
		if(sendmailList.size() > 0){
			System.debug(Logginglevel.WARN, '**一致しない求職者情報をメールする' + sendmailList.size());
			insert sendmailList;
		}
	}

    /**
     * 担当エリア表を元に割り当て表を取得し、求職者の所有者を更新する。
     *
     *
     */
	@TestVisible private static void processAllocation(
		Map<string, CustomObject3__c> matchTantouAreaMap
		,Map<string, CustomObject1__c> addMatchKyusyokusyaMap
	){
		// ----------------------------------------------------------------------------
		//パターン+転職希望時期を元に割り当て表を取得
        //担当エリア表と一致する住所を持つ求職者の所有者を更新
		// ----------------------------------------------------------------------------

        System.debug(Logginglevel.WARN, '**processAllocation*start*');
        System.debug(Logginglevel.WARN, '**addMatchKyusyokusyaMap**'+addMatchKyusyokusyaMap);
        System.debug(Logginglevel.WARN, '**addMatchKyusyokusyaMap**'+addMatchKyusyokusyaMap);

    	//担当エリア取得
    	CustomObject3__c tantouArea = null;
    	//求職者取得
    	CustomObject1__c kyusyokusya = null;
        //常勤、非常勤を判定
        String joukinType = null;
		//パターン
		String pattern = null;

		//所有者を設定した求職者を保持
		List<CustomObject1__c> targetKyusyokusyaList = new List<CustomObject1__c>();
		//所有者を設定した担当エリアを保持
		Map<String,CustomObject3__c> trgetTantouAreaMap = new Map<String,CustomObject3__c>();

        //担当エリアに一致した求職者に
        //該当する割り当て表がある場合所有者を更新する。

        for(String key : addMatchKyusyokusyaMap.keySet()){

			//所有者を変更した場合trueになる
			Boolean ownerSetflag = false;
			//add_start_2015/05/29 ogino #4915
			String debugMsg = '\r\nシステム情報：\r\n';
			//add_end_2015/05/29 ogino #4915

        	//keyは求職者id

        	//担当エリア取得
        	tantouArea = matchTantouAreaMap.get(key);
        	//求職者取得
        	kyusyokusya = addMatchKyusyokusyaMap.get(key);

            //常勤、非常勤を判定
            joukinType = getTimeType(kyusyokusya);

            System.debug(Logginglevel.WARN, '**joukinType**'+joukinType);

            //常勤、非常勤を判定
            if(joukinType == '常勤'){
            	//パターン取得
            	pattern = tantouArea.Distribution_pattern_fulltime__c;
            } else if(joukinType == '非常勤'){
            	//パターン取得
            	pattern = tantouArea.Distribution_pattern_shorttime__c;

            //2015/1/14 daidouzi add start #4485
            } else if(joukinType == '非常勤_20h以上'){
            	//パターン取得
            	pattern = tantouArea.Distribution_pattern_shorttime_20h__c;
            }
            //2015/1/14 daidouzi add end #4485

        	System.debug(Logginglevel.WARN, '********* パターン=' + pattern );

            //パターンがブランクの場合
            if(pattern == null){
            	//常勤/非常勤CC割りふり		担当者/担当キューIDが割りふり
            	System.debug(Logginglevel.WARN, '********* パターンがブランクの場合 1: ' );

	            //常勤、非常勤を判定
	            if(joukinType == '常勤'){
	            	//所有者更新  担当者/担当キューID
	            	//mod_start_2015/05/28 ogino
	            	//kyusyokusya.OwnerId = tantouArea.OwnerId__c;
	            	//ownerSetflag = true; //---------------------------//2015/3/2 daidouzi add #4634
                    if(tantouArea.OwnerId__c != null
                        && getActiveUserOrQueueMap().get(tantouArea.OwnerId__c) != null
                    ){
                        //所有者更新  担当者/担当キューID
                        kyusyokusya.OwnerId = tantouArea.OwnerId__c;
                        ownerSetflag = true;
                        //add_start_2015/09/18 ogino #7150
                        kyusyokusya.S2LAccountID__c = S2L_ACCOUNT_ID;
                        kyusyokusya.S2LCallerID__c = tantouArea.OwnerId_S2LClallerID__c;
                        //add_end_2015/09/18 ogino #7150

                    }else{
                        //String subject = 'IDが不正なため、所有者を変更できませんでした（tantouArea.OwnerId__c）';
                        //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                        //jobSeekerDto.subject = subject;
                        //jobSeekerDto.jobSeeker = kyusyokusya;
                        //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                        debugMsg += 'tantouArea.OwnerId__c\r\n';
                    }
                    //mod_end_2015/05/28 ogino #4915
	            } else if(joukinType == '非常勤'){
	            	//所有者更新  (非常勤)担当者/担当キューID
	            	//mod_start_2015/05/28 ogino #4915
	            	//kyusyokusya.OwnerId = tantouArea.PartTimeOwnerId__c;
	            	//ownerSetflag = true; //---------------------------//2015/3/2 daidouzi add #4634
                    if(tantouArea.PartTimeOwnerId__c != null
                        && getActiveUserOrQueueMap().get(tantouArea.PartTimeOwnerId__c) != null
                    ){
                        //所有者更新  (非常勤)担当者/担当キューID
                        kyusyokusya.OwnerId = tantouArea.PartTimeOwnerId__c;
                        ownerSetflag = true;
                        //add_start_2015/09/18 ogino #7150
                        kyusyokusya.S2LAccountID__c = S2L_ACCOUNT_ID;
                        kyusyokusya.S2LCallerID__c = tantouArea.PartTimeOwnerId_S2LCallerID__c;
                        //add_end_2015/09/18 ogino #7150

                    }else{
                        //String subject = 'IDが不正なため、所有者を変更できませんでした（tantouArea.PartTimeOwnerId__c）';
                        //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                        //jobSeekerDto.subject = subject;
                        //jobSeekerDto.jobSeeker = kyusyokusya;
                        //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                        debugMsg += 'tantouArea.PartTimeOwnerId__c\r\n';
                    }
                    //mod_end_2015/05/28 ogino #4915

	            //2015/1/14 daidouzi add start #4485
	            } else if(joukinType == '非常勤_20h以上'){
	            	//所有者更新  (非常勤)担当者/担当キューID
	            	//mod_start_2015/05/28 ogino #4915
	            	//kyusyokusya.OwnerId = tantouArea.PartTime_20_OwnerId__c;
	            	//ownerSetflag = true; //---------------------------//2015/3/2 daidouzi add #4634
                    if(tantouArea.PartTime_20_OwnerId__c != null
                        && getActiveUserOrQueueMap().get(tantouArea.PartTime_20_OwnerId__c) != null
                    ){
                        kyusyokusya.OwnerId = tantouArea.PartTime_20_OwnerId__c;
                        ownerSetflag = true;
                        //add_start_2015/09/18 ogino #7150
                        kyusyokusya.S2LAccountID__c = S2L_ACCOUNT_ID;
                        kyusyokusya.S2LCallerID__c = tantouArea.PartTime_20_OwnerId_S2LCallerID__c;
                        //add_end_2015/09/18 ogino #7150

                    }else{
                        //String subject = 'IDが不正なため、所有者を変更できませんでした（tantouArea.PartTime_20_OwnerId__c）';
                        //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                        //jobSeekerDto.subject = subject;
                        //jobSeekerDto.jobSeeker = kyusyokusya;
                        //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                        debugMsg += 'tantouArea.PartTime_20_OwnerId__c\r\n';
                    }
                    //mod_start_2015/05/28 ogino #4915
	            }
	            //2015/1/14 daidouzi add end #4485

				System.debug(Logginglevel.WARN, '********* パターンがブランクの場合2');

				//所有者を設定した場合
				if(ownerSetflag){

					//求職者と担当エリアを保持する
					targetKyusyokusyaList.add(kyusyokusya);
					//キーはcustomer_id__c
					//trgetTantouAreaMap.put(kyusyokusya.id,tantouArea);
					trgetTantouAreaMap.put(kyusyokusya.customer_id__c,tantouArea);

				}
                //add_start_2015/06/03 ogino #4915
                //CRJBの場合は、1025行目のcontinueでループを抜けるので、ここで一度格納する。
                JobSeekerDto jobSeekerDto = new JobSeekerDto();
                jobSeekerDto.debugMsg = debugMsg;
                jobSeekerDto.jobSeeker = kyusyokusya;
                jobSeekerDto.ownerSetFlag = ownerSetFlag;
                getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
            //add_end_2015/06/03 ogino #4915

				//担当エリアのパターンがブランクブランクの場合は処理をしない。
				continue;
            }

			//割り当て表を取得する。
			List<OwnerDistribution__c> ownerDistributionList = getOwnerDistributionList(pattern, kyusyokusya.Field142__c);

            System.debug(Logginglevel.WARN, '********* ownerDistributionList : ' + ownerDistributionList.size());

			Boolean matchFlag = false;

			//担当割り振り表のデリバリーフラグの値
			Boolean deliveryFlag = false;//2014/7/17 daidouzi add #3119

			//一致する割り当て表を探す 担当者割り当て表をループ
			for(OwnerDistribution__c ownerDistribution : ownerDistributionList){

				System.debug(Logginglevel.WARN, '********* ownerDistribution : ' + ownerDistribution);
				System.debug(Logginglevel.WARN, '********* ownerDistribution.Allegiance_test__c : ' + ownerDistribution.Allegiance_test__c);
				System.debug(Logginglevel.WARN, '********* ownerDistribution.entry_category__c : ' + ownerDistribution.entry_category__c);
				System.debug(Logginglevel.WARN, '********* kyusyokusya.entry_category__c : ' + kyusyokusya.entry_category__c);
				System.debug(Logginglevel.WARN, '********* kyusyokusya.retirement_intention__c : ' + kyusyokusya.retirement_intention__c);

				//求職者：踏み絵
				String allegianceTest = '';
				//求職者：登録カテゴリ
				String entryCategory = '';

				//if(kyusyokusya.Allegiance_test__c != null){
				if(kyusyokusya.retirement_intention__c != null){
					//allegianceTest = kyusyokusya.Allegiance_test__c;
					//退職意向
					allegianceTest = kyusyokusya.retirement_intention__c;
				}

				if(kyusyokusya.entry_category__c != null){
					entryCategory = kyusyokusya.entry_category__c;
				}

				//登録カテゴリと踏み絵が含まれていない場合
				if(ownerDistribution.Allegiance_test__c == null
					&& ownerDistribution.entry_category__c == null

				){
					//該当した場合
					matchFlag = true;
					/*//2014/09/02 daidouzi delete #3360
					//2014/7/17 daidouzi add start #3119
					if(ownerDistribution.DeliveryFlag__c){
						deliveryFlag = true;
					}
					//2014/7/17 daidouzi add end #3119
					*/
					//担当割り当て表のDVフラグを保持する
					deliveryFlag = ownerDistribution.DeliveryFlag__c; //2014/09/02 daidouzi add #3360


					System.debug(Logginglevel.WARN, '********* 該当した場合 : 1');
					System.debug(Logginglevel.WARN, '********* '+ownerDistribution.id);

				//踏み絵がある場合かつ、登録カテゴリがない場合
				}else if(ownerDistribution.Allegiance_test__c != null
					&& ownerDistribution.Allegiance_test__c.contains(allegianceTest)
					&& ownerDistribution.entry_category__c == null

				){
					//該当した場合
					matchFlag = true;

					/*//2014/09/02 daidouzi delete #3360
					//2014/7/17 daidouzi add start #3119
					if(ownerDistribution.DeliveryFlag__c){
						deliveryFlag = true;
					}
					//2014/7/17 daidouzi add end #3119
					*/
					//担当割り当て表のDVフラグを保持する
					deliveryFlag = ownerDistribution.DeliveryFlag__c; //2014/09/02 daidouzi add #3360

					System.debug(Logginglevel.WARN, '********* 該当した場合 : 2');
					System.debug(Logginglevel.WARN, '********* 該当した場合 : 2'+ownerDistribution.id);

				//登録カテゴリある場合かつ踏みえがない場合
				}else if(ownerDistribution.entry_category__c != null
					&& ownerDistribution.entry_category__c.contains(entryCategory)
					&& ownerDistribution.Allegiance_test__c == null

				){
					//該当した場合
					matchFlag = true;
					/*//2014/09/02 daidouzi delete #3360
					//2014/7/17 daidouzi add start #3119
					if(ownerDistribution.DeliveryFlag__c){
						deliveryFlag = true;
					}
					//2014/7/17 daidouzi add end #3119
					*/
					//担当割り当て表のDVフラグを保持する
					deliveryFlag = ownerDistribution.DeliveryFlag__c; //2014/09/02 daidouzi add #3360

					//2014/7/17 daidouzi add end #3119
					System.debug(Logginglevel.WARN, '********* 該当した場合 : 3');
					System.debug(Logginglevel.WARN, '********* 該当した場合 : 3'+ownerDistribution.id);

				//登録カテゴリと踏み絵が含まれている場合
				}else if(ownerDistribution.Allegiance_test__c != null
					&& ownerDistribution.Allegiance_test__c.contains(allegianceTest)
					&& ownerDistribution.entry_category__c != null
					&& ownerDistribution.entry_category__c.contains(entryCategory)

				){
					//該当した場合
					matchFlag = true;

					/* //2014/09/02 daidouzi delete #3360
					//2014/7/17 daidouzi add start #3119
					if(ownerDistribution.DeliveryFlag__c){
						deliveryFlag = true;
					}
					//2014/7/17 daidouzi add end #3119
					*/

					//担当割り当て表のDVフラグを保持する
					deliveryFlag = ownerDistribution.DeliveryFlag__c; //2014/09/02 daidouzi add #3360

					//2014/7/17 daidouzi add end #3119
					System.debug(Logginglevel.WARN, '********* 該当した場合 : 4');
					System.debug(Logginglevel.WARN, '********* 該当した場合 : 4'+ownerDistribution.id);
				}
			}

			//一致した場合
			if(matchFlag){

	            //常勤、非常勤を判定
	            if(joukinType == '常勤'){
	            	//所有者更新  担当者/担当キューID
	            	//mod_start_2015/05/28 ogino #4915
	            	//kyusyokusya.OwnerId = tantouArea.OwnerId__c;
	            	//ownerSetflag = true; //---------------------------//2015/3/2 daidouzi add #4634
                    if(tantouArea.OwnerId__c != null
                        && getActiveUserOrQueueMap().get(tantouArea.OwnerId__c) != null
                    ){
                        //所有者更新  担当者/担当キューID
                        kyusyokusya.OwnerId = tantouArea.OwnerId__c;
                        ownerSetflag = true;
                        //add_start_2015/09/18 ogino #7150
                        kyusyokusya.S2LAccountID__c = S2L_ACCOUNT_ID;
                        kyusyokusya.S2LCallerID__c = tantouArea.OwnerId_S2LClallerID__c;
                        //add_end_2015/09/18 ogino #7150

                    }else{
                        //String subject = 'IDが不正なため、所有者を変更できませんでした（matchFlag:true tantouArea.OwnerId__c）';
                        //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                        //jobSeekerDto.subject = subject;
                        //jobSeekerDto.jobSeeker = kyusyokusya;
                        //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                        debugMsg += 'matchFlag:true tantouArea.OwnerId__c\r\n';
                    }
                    //mod_end_2015/05/28 ogino #4915
	            } else if(joukinType == '非常勤'){
	            	//所有者更新  (非常勤)担当者/担当キューID
	            	//mod_start_2015/05/28 ogino #4915
	            	//kyusyokusya.OwnerId = tantouArea.PartTimeOwnerId__c;
	            	//ownerSetflag = true; //---------------------------//2015/3/2 daidouzi add #4634
                    if(tantouArea.PartTimeOwnerId__c != null
                        && getActiveUserOrQueueMap().get(tantouArea.PartTimeOwnerId__c) != null
                    ){
                        kyusyokusya.OwnerId = tantouArea.PartTimeOwnerId__c;
                        ownerSetflag = true;
                        //add_start_2015/09/18 ogino #7150
                        kyusyokusya.S2LAccountID__c = S2L_ACCOUNT_ID;
                        kyusyokusya.S2LCallerID__c = tantouArea.PartTimeOwnerId_S2LCallerID__c;
                        //add_end_2015/09/18 ogino #7150

                    }else{
                        //String subject = 'IDが不正なため、所有者を変更できませんでした（matchFlag:true tantouArea.PartTimeOwnerId__c）';
                        //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                        //jobSeekerDto.subject = subject;
                        //jobSeekerDto.jobSeeker = kyusyokusya;
                        //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                        debugMsg += 'matchFlag:true tantouArea.PartTimeOwnerId__c\r\n';
                    }
                    //mod_end_2015/05/28 ogino #4915

	            //2015/1/14 daidouzi add start #4485
	            } else if(joukinType == '非常勤_20h以上'){
	            	//所有者更新  (非常勤)担当者/担当キューID
	            	//mod_start_2015/05/28 ogino #4915
	            	//kyusyokusya.OwnerId = tantouArea.PartTime_20_OwnerId__c;
	            	//ownerSetflag = true; //---------------------------//2015/3/2 daidouzi add #4634
                    if(tantouArea.PartTimeOwnerId__c != null
                        && getActiveUserOrQueueMap().get(tantouArea.PartTimeOwnerId__c) != null
                    ){
                        kyusyokusya.OwnerId = tantouArea.PartTime_20_OwnerId__c;
                        ownerSetflag = true;
                        //add_start_2015/09/18 ogino #7150
                        kyusyokusya.S2LAccountID__c = S2L_ACCOUNT_ID;
                        kyusyokusya.S2LCallerID__c = tantouArea.PartTime_20_OwnerId_S2LCallerID__c;
                        //add_end_2015/09/18 ogino #7150

                    }else{
                        //String subject = 'IDが不正なため、所有者を変更できませんでした（matchFlag:true tantouArea.PartTime_20_OwnerId__c）';
                        //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                        //jobSeekerDto.subject = subject;
                        //jobSeekerDto.jobSeeker = kyusyokusya;
                        //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                        debugMsg += 'matchFlag:true tantouArea.PartTime_20_OwnerId__c\r\n';
                    }
                    //mod_end_2015/05/28 ogino #4915
	            }
	            //2015/1/14 daidouzi add end #4485

	            /* //2014/09/02 daidouzi delete #3360
	            //2014/7/17 daidouizi add start #3119
	            //DVフラグがtrueの場合
	            if(deliveryFlag){
		        	kyusyokusya.DeliveryFlag__c = true;
		        	kyusyokusya.DeliveryFlagDebug__c += '[setreqOwnerCustam:001:true]\n';
	            }
	            //2014/7/17 daidouizi add end #3119
	            */

	            //DVフラグを設定する
	            kyusyokusya.DeliveryFlag__c = deliveryFlag; //2014/09/02 daidouzi add #3360


				System.debug(Logginglevel.WARN, '********* 一致した場合1');
				System.debug(Logginglevel.WARN, '********* DVフラグ='+kyusyokusya.DeliveryFlag__c);

		        //2015/05/12 ogino del start #5385
		        //kyusyokusya.DeliveryFlagDebug__c += Datetime.now()+ '[setreqOwnerCustam:002:'+kyusyokusya.DeliveryFlag__c+']\n';
		        //2015/05/12 ogino del end #5385


	        //一致しない場合、または対象レコードが存在しない場合
			}else {

	            //常勤、非常勤を判定
	            if(joukinType == '常勤'){
	            	//所有者更新  メディア企画担当者キューID
	            	//mod_start_2015/05/28 ogino #4915
	            	//kyusyokusya.OwnerId = tantouArea.FC_OwnerId__c;
	            	//ownerSetflag = true; //---------------------------//2015/3/2 daidouzi add #4634
                    if(tantouArea.FC_OwnerId__c != null
                        && getActiveUserOrQueueMap().get(tantouArea.FC_OwnerId__c) != null
                    ){
                        kyusyokusya.OwnerId = tantouArea.FC_OwnerId__c;
                        ownerSetflag = true;

                    }else{
                        //String subject = 'IDが不正なため、所有者を変更できませんでした（matchFlag:false tantouArea.FC_OwnerId__c）';
                        //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                        //jobSeekerDto.subject = subject;
                        //jobSeekerDto.jobSeeker = kyusyokusya;
                        //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                        debugMsg += 'matchFlag:false tantouArea.FC_OwnerId__c\r\n';
                    }
                    //mod_end_2015/05/28 ogino #4915

                    //del_start_2016/03/25 ogino #10632
                    ////2014/7/22 daidouzi add start #3135
                    ////njb_sa_pretelを含む場合、かつFCCの場合のステータス変更する
                    //if(kyusyokusya.action__c != null && kyusyokusya.action__c.indexOf('njb_sa_pretel') != -1){
                    //    kyusyokusya.FC_status__c = '面談済み（電話登録経由）';
                    //}
                    ////2014/7/22 daidouzi add end #3135
                    //del_end_2016/03/25 ogino #10632

	            } else if(joukinType == '非常勤'){

	            	//所有者更新  (非常勤)メディア企画担当者キューID
	            	//mod_start_2015/05/28 ogino #4915
	            	//kyusyokusya.OwnerId = tantouArea.PartTime_FC_OwnerId__c;
	            	//ownerSetflag = true; //---------------------------//2015/3/2 daidouzi add #4634
                    if(tantouArea.FC_OwnerId__c != null
                        && getActiveUserOrQueueMap().get(tantouArea.PartTime_FC_OwnerId__c) != null
                    ){
                        kyusyokusya.OwnerId = tantouArea.PartTime_FC_OwnerId__c;
                        ownerSetflag = true;

                    }else{
                        //String subject = 'IDが不正なため、所有者を変更できませんでした（matchFlag:false tantouArea.PartTime_FC_OwnerId__c）';
                        //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                        //jobSeekerDto.subject = subject;
                        //jobSeekerDto.jobSeeker = kyusyokusya;
                        //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                        debugMsg += 'matchFlag:false tantouArea.PartTime_FC_OwnerId__c\r\n';
                    }
                    //mod_end_2015/05/28 ogino #4915

                    //del_start_2016/03/25 ogino #10632
                    ////2014/7/22 daidouzi add start #3135
                    ////njb_sa_pretelを含む場合、かつFCCの場合のステータス変更する
                    //if(kyusyokusya.action__c != null && kyusyokusya.action__c.indexOf('njb_sa_pretel') != -1){
                    //    kyusyokusya.FC_status__c = '面談済み（電話登録経由）';
                    //}
                    ////2014/7/22 daidouzi add end #3135
                    //del_end_2016/03/25 ogino #10632

	            //2015/1/14 daidouzi add start #4485
	            } else if(joukinType == '非常勤_20h以上'){

	            	//所有者更新  (非常勤20時間以上)メディア企画担当者キューID
	            	//mod_start_2015/05/28 ogino #4915
	            	//kyusyokusya.OwnerId = tantouArea.PartTime_20_FC_OwnerId__c;
	            	//ownerSetflag = true; //---------------------------//2015/3/2 daidouzi add #4634
                    if(tantouArea.PartTime_20_FC_OwnerId__c != null
                        && getActiveUserOrQueueMap().get(tantouArea.PartTime_20_FC_OwnerId__c) != null
                    ){
                        kyusyokusya.OwnerId = tantouArea.PartTime_20_FC_OwnerId__c;
                        ownerSetflag = true;

                    }else{
                        //String subject = 'IDが不正なため、所有者を変更できませんでした（matchFlag:false tantouArea.PartTime_20_FC_OwnerId__c）';
                        //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                        //jobSeekerDto.subject = subject;
                        //jobSeekerDto.jobSeeker = kyusyokusya;
                        //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                        debugMsg += 'matchFlag:false tantouArea.PartTime_20_FC_OwnerId__c\r\n';
                    }
                    //mod_end_2015/05/28 ogino #4915
                    //del_start_2016/03/25 ogino #10632
                    ////njb_sa_pretelを含む場合、かつFCCの場合のステータス変更する
                    //if(kyusyokusya.action__c != null && kyusyokusya.action__c.indexOf('njb_sa_pretel') != -1){
                    //    kyusyokusya.FC_status__c = '面談済み（電話登録経由）';
                    //}
                    //del_end_2016/03/25 ogino #10632

	            }
	            //2015/1/14 daidouzi add end #4485

	            //一致しない場合は、条件なしでfalseを設定する
	            kyusyokusya.DeliveryFlag__c = false; //2014/09/02 daidouzi add #3360

				System.debug(Logginglevel.WARN, '********* 一致しない場合='+kyusyokusya.OwnerId);
			}


        	/* 看護学生の場合の処理は担当エリアの前に変更
        	//2014/7/22 daidouzi add start #3129
        	//★保有資格が看護学生と一致の場合はFalse
	        //if (kyusyokusya.Field14__c != null && kyusyokusya.Field14__c.indexOf('看護学生') != -1) { //2014/8/1 daidouizi delete #3179
	        if (kyusyokusya.Field14__c == '看護学生') { //2014/8/1 daidouizi add #3179
	        	System.debug(Logginglevel.WARN, '********* ★保有資格が看護学生と一致');
        		kyusyokusya.DeliveryFlag__c = false;
		        kyusyokusya.DeliveryFlagDebug__c += Datetime.now()+ '[setreqOwnerCustam:003:false]\n';
		    	kyusyokusya.DeliveryFlagDebug__c += Datetime.now()+ '[setreqOwnerCustam:004:'+kyusyokusya.DeliveryFlag__c+']\n';
	        }
        	//2014/7/22 daidouzi add end #3129
        	*/

		    //2015/05/12 ogino del start #5385
		    //kyusyokusya.DeliveryFlagDebug__c += Datetime.now()+ '[setreqOwnerCustam:005:'+kyusyokusya.DeliveryFlag__c+']\n';
		    //2015/05/12 ogino del end #5385


			//所有者を設定した場合
			if(ownerSetflag){
				//求職者と担当エリアを保持する
				targetKyusyokusyaList.add(kyusyokusya);

				//シリアル（システム用）がある場合
				if(kyusyokusya.customer_id__c != null){
					//新規の場合IDがないため、ほかのユニーク項目を使用する
					//trgetTantouAreaMap.put(kyusyokusya.id,tantouArea);
					trgetTantouAreaMap.put(kyusyokusya.customer_id__c, tantouArea);
				}

			}
			//add_start_2015/05/29 ogino #4915
			JobSeekerDto jobSeekerDto = new JobSeekerDto();
            jobSeekerDto.debugMsg = debugMsg;
            jobSeekerDto.jobSeeker = kyusyokusya;
            jobSeekerDto.ownerSetFlag = ownerSetFlag;
            getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
			//add_end_2015/05/29 ogino #4915
        }

        //2015/3/2 daidouzi add start #4634
        //メール送信 所有者と担当エリアのその他項目メール送信。queryの最適化は後ほど対応予定
		//所有者が設定された求職者の所有者にメール送信するため、ユーザを取得する
		Map<String, List<User>> userListMap = getUserForOwnerId(targetKyusyokusyaList);
		//afterでメール送信するため、保持する
		Utility.setUserListForAllocation(userListMap);
		System.debug('----所有者が設定された求職者の所有者にメール送信　件数---'+userListMap);

		//担当エリアのその他アドレスに送信するため、アドレスを取得する
		Map<String, List<String>> userListForTantouArea = getSendTargetAddress(targetKyusyokusyaList, trgetTantouAreaMap);
		//afterでメール送信するため、保持する
		Utility.setUserListForTantouArea(userListForTantouArea);
		System.debug('----担当エリアのその他アドレスに送信対象---'+userListForTantouArea);

		//2015/3/2 daidouzi add start #4634

	}

	/**
	 * 登録サイトを振り分ける。
	 *
	 * NJB⇒RJB⇒CJB⇒その他の順番で評価する
	 */
	public static String distributesSite(CustomObject1__c c){

		String site = null;

        // 希望職種から登録サイトを決定

		//2014/4/10 daidouzi add start #2629
		//Field16__c★希望職種項目を比較

		System.debug('----c.Field16__c---'+c.Field16__c);
		System.debug('----c.Field14__c---'+c.Field14__c);


		//null以外の場合
		if(c.Field16__c != null && c.Field16__c != 'その他'){  //--------------------------block1

	        //NJBの場合
	        if (c.Field16__c.contains('看護師（正看・准看）') ) { //--------------------------block1-4

	            site = 'NJB';

			//RJBの場合
	        } else if (c.Field16__c.contains('理学療法士（PT）') //--------------------------block1-2
	        	|| c.Field16__c.contains('作業療法士（OT）')
	        	|| c.Field16__c.contains('言語聴覚士（ST）')
	        ) {

	            site = 'PTOTJB';

	        //CJBの場合
	        } else if (c.Field16__c.contains('ケアマネジャー') //--------------------------block1-3
	        	|| c.Field16__c.contains('居宅ケアマネジャー')
	        	|| c.Field16__c.contains('施設ケアマネジャー')
	        	|| c.Field16__c.contains('GHケアマネジャー')
	        	|| c.Field16__c.contains('相談員')
	        	|| c.Field16__c.contains('サービス提供責任者')
	        	|| c.Field16__c.contains('介護職員')
	        	|| c.Field16__c.contains('管理職')
	        	|| c.Field16__c.contains('グループホーム計画作成')
	        ) {

	            site = 'CJB';

	        }else{
	        	site = 'その他';
	        }

        //Field16__c★希望職種を比較 nullまたは、その他の場合
        }else if (c.Field16__c == null || c.Field16__c == 'その他') { //--------------------------block2

	        //Field14__c★保有資格項目を比較する

	        //NJBの場合
	        if (c.Field14__c == null
	        	|| c.Field14__c.contains('看護師')
	        	|| c.Field14__c.contains('准看護師')
	        	|| c.Field14__c.contains('助産師')
	        	|| c.Field14__c.contains('保健師')
	        	|| c.Field14__c.contains('看護学生')
	        	|| c.Field14__c.contains('その他')
	        ) {
	            site = 'NJB';

	        //RJBの場合
	        }else if (c.Field14__c != null &&
	        	(
	        		c.Field14__c.contains('理学療法士（PT）')
	        		|| c.Field14__c.contains('作業療法士（OT）')
	        		|| c.Field14__c.contains('言語聴覚士（ST）')
	        		|| c.Field14__c.contains('学生') //2014/04/15 daidouzi add #2687
	        	)
	        ) {
	            site = 'PTOTJB';

	        //CJBの場合
	        } else if (c.Field14__c != null &&
	        	(
		        	c.Field14__c.contains('ケアマネジャー')
		        	|| c.Field14__c.contains('経験ケアマネジャー')
		        	|| c.Field14__c.contains('未経験ケアマネジャー')
		        	|| c.Field14__c.contains('取得見込ケアマネジャー')
		        	|| c.Field14__c.contains('主任ケアマネジャー')
		        	|| c.Field14__c.contains('介護福祉士')
		        	|| c.Field14__c.contains('社会福祉士')
		        	|| c.Field14__c.contains('ヘルパー1級')
		        	|| c.Field14__c.contains('ヘルパー2級')
		        	|| c.Field14__c.contains('介護職員基礎研修')
		        	|| c.Field14__c.contains('社会福祉主事')
	        	)
	        ) {
	            site = 'CJB';

	        } else {
	            site = 'その他';
	        }

        } else { //--------------------------block3
            site = 'その他';
        }
		//2014/4/10 daidouzi add end #2629

		System.debug('----site---'+site);

        return site;
	}

	/**
	 * 該当する都道府県と登録サイトの担当エリア表を取得
	*/
	@TestVisible private static List<CustomObject3__c> getTantouAeraListCustom(CustomObject1__c c ,String site){
        // 該当する都道府県と登録サイトの担当エリア表を取得
        List<CustomObject3__c> tbl = new List<CustomObject3__c>([
        	SELECT
        		Name,
        		key__c,
        		OwnerId__c,
        		owner.Name,
        		PartTimeOwnerId__c,
        		FC_OwnerId__c,
        		PartTime_FC_OwnerId__c,
        		PartTime_20_FC_OwnerId__c,
        		key_special__c //key(市を除いた区のみ)
        		,Distribution_pattern_fulltime__c
        		,Distribution_pattern_shorttime__c
        		,Distribution_pattern_shorttime_20h__c
        		,PartTime_20_OwnerId__c
                //add_start_2015/09/18 ogino #7150
                ,OwnerId_S2LClallerID__c
                ,PartTimeOwnerId_S2LCallerID__c
                ,PartTime_20_OwnerId_S2LCallerID__c
                //add_end_2015/09/18 ogino #7150

        		,OthersSendAddress__c //--------------------
        	from CustomObject3__c
        	where
        		(
        			field1__c = :c.field6__c //都道府県
        			or key__c = null
        		)
        		and site__c = :site
        		and FC_OwnerId__c != null

        	order by len__c asc
        ]);

        return tbl;
	}


	/**
	 * 該当する都道府県と登録サイトの担当エリア表を取得
	*/
    @TestVisible private static List<CustomObject3__c> getTantouAeraListCustomDesc(CustomObject1__c c ,String site){
        // キーが住所に前方一致するもので最も長いkeyを検索 （key=神奈川県横浜市, 住所=神奈川県横浜市西区のケース）
        //このマッチングはtblを逆から走査するため登録カテゴリがnullのデータを先頭に持ってきたtmpTblで走査を行う

        List<CustomObject3__c> tmpTbl = new List<CustomObject3__c>([
        	SELECT
        		Name,
        		key__c,
        		OwnerId__c,
        		owner.Name,
        		PartTimeOwnerId__c,
        		FC_OwnerId__c,
        		PartTime_FC_OwnerId__c,
        		PartTime_20_OwnerId__c,
        		PartTime_20_FC_OwnerId__c,
        		OthersSendAddress__c,//---------------------

        		Distribution_pattern_fulltime__c,
        		Distribution_pattern_shorttime__c,
        		Distribution_pattern_shorttime_20h__c,
        		key_special__c //key(市を除いた区のみ)
                //add_start_2015/09/18 ogino #7150
                ,OwnerId_S2LClallerID__c
                ,PartTimeOwnerId_S2LCallerID__c
                ,PartTime_20_OwnerId_S2LCallerID__c
                //add_end_2015/09/18 ogino #7150
        	from CustomObject3__c
        	where
        		(
        			field1__c = :c.field6__c
        			or key__c = null
        		)
        		and site__c = :site
        		and FC_OwnerId__c != null

        	order by len__c desc
        ]);

        return tmpTbl;
	}

	/**
	 * 担当者振り分け表を取得
	*/
	//mod_start_2015/10/28 ogino #7310
    //@TestVisible private static List<OwnerDistribution__c> getOwnerDistributionList(String pattern, String reqDate){
    public static List<OwnerDistribution__c> getOwnerDistributionList(String pattern, String reqDate){
    //mod_end_2015/10/28 ogino #7310

        List<OwnerDistribution__c> tmpTbl = new List<OwnerDistribution__c>([
        	SELECT
        		Name,
        		Distribution_pattern__c,
        		Req_date__c,
        		entry_category__c,
        		Allegiance_test__c,
        		DeliveryFlag__c //2014/7/17 daidouizi add start #3119
        	from OwnerDistribution__c
        	where
        		Distribution_pattern__c =:pattern
        		and Req_date__c =:reqDate

        ]);

        return tmpTbl;
	}


	/**
	 * 常勤、非常勤を判定
	 * @param Kyushokusha 求職者
	 * @param Tantou 担当エリア表
	 */
    //mod_start_2015/10/28 ogino #7310
    //@TestVisible private static String getTimeType(CustomObject1__c Kyushokusha) {
    public static String getTimeType(CustomObject1__c Kyushokusha) {
    //mod_end_2015/10/28 ogino #7310

        System.debug( '>>>>>> getTimeType');
        System.debug( '>>>>>> Kyushokusha.Field17__c＝'+Kyushokusha.Field17__c);

        String timeType = null;

		//求職者：★希望雇用形態が「常勤」、「常勤・非常勤不問」、「常勤(夜勤含む)」、「常勤(日勤のみ)」、「こだわらない」のいずれかで
        if (
        	Kyushokusha.Field17__c == '常勤'
        	|| Kyushokusha.Field17__c == '常勤・非常勤不問'
        	|| Kyushokusha.Field17__c == '常勤(夜勤含む)'
        	|| Kyushokusha.Field17__c == '常勤(日勤のみ)'
        	|| Kyushokusha.Field17__c == 'こだわらない'

        ) {
        	timeType = '常勤';

		//求職者：★希望雇用形態が「非常勤」、「非常勤(扶養内)」、「非常勤（扶養範囲内で勤務希望）」、のいずれかで
        } else if (
        	Kyushokusha.Field17__c == '非常勤'
        	|| Kyushokusha.Field17__c == '非常勤(扶養内)'
        	|| Kyushokusha.Field17__c == '非常勤（扶養範囲内で勤務希望）'
        ) {

        	timeType = '非常勤';

        //2015/1/14 daidouzi add start #4485
        } else if (Kyushokusha.Field17__c == '非常勤(週20時間以上勤務)'){

        	timeType = '非常勤_20h以上';

        }
        //2015/1/14 daidouzi add end #4485



        return timeType;

    }



    // ---------------------------------------------
    // 求職者の所有者をルールにしたがってセットする。カスタムボタン用
    // NJBのみの処理。
    // ---------------------------------------------
    public static void setOwnerRunForPage(CustomObject1__c[] co, String selectValue) {

		System.debug( '>>>>>> setOwnerRunForPage start');

        //住所が一致した求職者
        Map<String,CustomObject1__c> addMatchKyusyokusyaMap = new Map<String,CustomObject1__c>();

        //住所が一致していない求職者
        Map<String,CustomObject1__c> addNotMatchKyusyokusyaMap = new Map<String,CustomObject1__c>();

        //住所が一致していない求職者
        List<CustomObject1__c> lastAddNotMatchKyusyokusyaList = new List<CustomObject1__c>();

        //一致した担当エリア  求職者id=>担当エリア
        Map<String ,CustomObject3__c> matchTantouAreaMap = new Map<String ,CustomObject3__c>();


		// ----------------------------------------------------------------------------
        //担当エリア表と一致する住所を持つ求職者を絞り込む パターン1、2
        //メソッド内で、Mapに必要な情報をつめる
		// ----------------------------------------------------------------------------
    	searchMatcheAddress(
	    	co
	    	,addMatchKyusyokusyaMap
	    	,addNotMatchKyusyokusyaMap
	    	,matchTantouAreaMap
 	   	);

        System.debug(Logginglevel.WARN, '--------addNotMatchKyusyokusyaMap.values.size()'+addNotMatchKyusyokusyaMap.values().size());
        System.debug(Logginglevel.WARN, '--------パターン1,2に住所一致しない求職者');


		// ----------------------------------------------------------------------------
        //担当エリア表と一致する住所を持つ求職者を絞り込む
		//パターン1,2に住所一致しない求職者
        //メソッド内で、Mapに必要な情報をつめる
		// ----------------------------------------------------------------------------
		searchMatcheAddressSecond(
	    	addMatchKyusyokusyaMap
	    	,addNotMatchKyusyokusyaMap
	    	,matchTantouAreaMap
    		,lastAddNotMatchKyusyokusyaList
 		);

		CustomObject3__c tantouArea = null;
		CustomObject1__c kyusyokusya = null;

		//所有者を設定した求職者を保持
		List<CustomObject1__c> targetKyusyokusyaList = new List<CustomObject1__c>();
		//所有者を設定した担当エリアを保持
		Map<String,CustomObject3__c> trgetTantouAreaMap = new Map<String,CustomObject3__c>();


        //担当エリアに一致した求職者に
        //該当する割り当て表がある場合所有者を更新する。
        for(String key : addMatchKyusyokusyaMap.keySet()){

			//所有者を設定した判定用
			Boolean ownerSetflag = false;
			//add_start_2015/05/29 ogino #4915
			String debugMsg = '\r\nシステム情報：\r\n';
			//add_end_2015/05/29 ogino #4915

        	//keyは求職者id
        	//担当エリア取得
        	tantouArea = matchTantouAreaMap.get(key);
        	//求職者取得
        	kyusyokusya = addMatchKyusyokusyaMap.get(key);

			System.debug(Logginglevel.WARN, '--------selectValue=' + selectValue);
			System.debug(Logginglevel.WARN, '--------tantouArea=' + tantouArea);
			System.debug(Logginglevel.WARN, '--------kyusyokusya=' + kyusyokusya);

			if(kyusyokusya != null && tantouArea !=null){

	 			//選択値によって変更する
	 			if(selectValue == '常勤'){

	 				//担当者/担当キューID
	 				//mod_start_2015/05/28 ogino #4915
	 				//kyusyokusya.OwnerId = tantouArea.OwnerId__c;
	 				//ownerSetflag = true;//------------------------------------//2015/3/2 daidouzi add #4634
                    if(tantouArea.OwnerId__c != null
                        && getActiveUserOrQueueMap().get(tantouArea.OwnerId__c) != null
                    ){
                        kyusyokusya.OwnerId = tantouArea.OwnerId__c;
                        ownerSetflag = true;

                    }else{
                        //String subject = 'IDが不正なため、所有者を変更できませんでした（VF tantouArea.OwnerId__c）';
                        //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                        //jobSeekerDto.subject = subject;
                        //jobSeekerDto.jobSeeker = kyusyokusya;
                        //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                        debugMsg += 'VF tantouArea.OwnerId__c\r\n';
                    }
                    //mod_end_2015/05/28 ogino #4915

	 			}else if(selectValue == '扶養内'){

	 				//(非常勤)担当者/担当キューID
	 				//mod_start_2015/05/28 ogino #4915
	 				//kyusyokusya.OwnerId = tantouArea.PartTimeOwnerId__c;
	 				//ownerSetflag = true;//------------------------------------//2015/3/2 daidouzi add #4634
                    if(tantouArea.PartTimeOwnerId__c != null
                        && getActiveUserOrQueueMap().get(tantouArea.PartTimeOwnerId__c) != null
                    ){
                        kyusyokusya.OwnerId = tantouArea.PartTimeOwnerId__c;
                        ownerSetflag = true;

                    }else{
                        //String subject = 'IDが不正なため、所有者を変更できませんでした（VF tantouArea.PartTimeOwnerId__c）';
                        //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                        //jobSeekerDto.subject = subject;
                        //jobSeekerDto.jobSeeker = kyusyokusya;
                        //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                        debugMsg += 'VF tantouArea.PartTimeOwnerId__c\r\n';
                    }
                    //mod_end_2015/05/28 ogino #4915

	 			}else if(selectValue == 'FCC'){

	 				//メディア企画担当者キューID
	 				//mod_start_2015/05/28 ogino #4915
	 				//kyusyokusya.OwnerId = tantouArea.FC_OwnerId__c;
	 				//ownerSetflag = true;//------------------------------------//2015/3/2 daidouzi add #4634
                    if(tantouArea.FC_OwnerId__c != null
                        && getActiveUserOrQueueMap().get(tantouArea.FC_OwnerId__c) != null
                    ){
                        kyusyokusya.OwnerId = tantouArea.FC_OwnerId__c;
                        ownerSetflag = true;

                    }else{
                        //String subject = 'IDが不正なため、所有者を変更できませんでした（VF tantouArea.PartTimeOwnerId__c）';
                        //JobSeekerDto jobSeekerDto = new JobSeekerDto();
                        //jobSeekerDto.subject = subject;
                        //jobSeekerDto.jobSeeker = kyusyokusya;
                        //getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
                        debugMsg += 'VF tantouArea.PartTimeOwnerId__c\r\n';
                    }
                    //mod_end_2015/05/28 ogino #4915

	 			}

	 			//カスタムボタン空の場合
			}

			//所有者を設定した場合
			if(ownerSetflag){
				//求職者と担当エリアを保持する
				targetKyusyokusyaList.add(kyusyokusya);

				//シリアル（システム用）がある場合
				if(kyusyokusya.customer_id__c != null){
					//beforeトリガの場合、新規の場合idがないためユニー項目使用する。
					//trgetTantouAreaMap.put(kyusyokusya.id,tantouArea);
					trgetTantouAreaMap.put(kyusyokusya.customer_id__c,tantouArea);
				}
			}
			//add_start_2015/05/29 ogino #4915
            JobSeekerDto jobSeekerDto = new JobSeekerDto();
            jobSeekerDto.debugMsg = debugMsg;
            jobSeekerDto.jobSeeker = kyusyokusya;
            jobSeekerDto.ownerSetFlag = ownerSetFlag;
            getErrChangeOwnerJobSeekerDtoList().add(jobSeekerDto);
            //add_end_2015/05/29 ogino #4915

        }

        //メール送信   所有者と担当エリアのその他項目メール送信。queryの最適化は後ほど対応予定

		//2015/3/2 daidouzi add start #4634
		//所有者が設定された求職者の所有者にメール送信するため、ユーザを取得する
		Map<String, List<User>> userListMap = getUserForOwnerId(targetKyusyokusyaList);
		//afterでメール送信するため、保持する
		Utility.setUserListForAllocation(userListMap);
		System.debug('----所有者が設定された求職者の所有者にメール送信　件数---'+userListMap);

		//求職者に所有者を設定したときに使用した担当エリアのその他アドレスに送信するため、アドレスを取得する
		Map<String, List<String>> userListForTantouArea = getSendTargetAddress(targetKyusyokusyaList, trgetTantouAreaMap);
		//afterでメール送信するため、保持する
		Utility.setUserListForTantouArea(userListForTantouArea);
		System.debug('----担当エリアのその他アドレスに送信対象---'+userListForTantouArea);

		//2015/3/2 daidouzi add end #4634
    }

	/**
	 * 担当エリア表と一致する住所を持つ求職者を絞り込む パターン1、2
	 *
	 * @param co 対象の求職者リスト
	 * @param addMatchKyusyokusyaMap 住所が一致した求職者
	 * @param addNotMatchKyusyokusyaMap 住所が一致していない求職者
	 * @param matchTantouAreaMap 一致した担当エリア  求職者id=>担当エリア
	 *
	 */
    @TestVisible private static void searchMatcheAddress(
    	List<CustomObject1__c> co
    	,Map<String,CustomObject1__c> addMatchKyusyokusyaMap
    	,Map<String,CustomObject1__c> addNotMatchKyusyokusyaMap
    	,Map<String ,CustomObject3__c> matchTantouAreaMap
    ){

		System.debug( '>>>>>> searchMatcheAddress start');

		//登録サイト
        String site;

        ///常勤、非常勤
        //String timeType;
        //
        Boolean found = false;

		//送信メール
		List<SendMail__c> sendmailList = new List<SendMail__c>();

        for (CustomObject1__c kyusyokusya: co) {

            System.debug(Logginglevel.WARN, '------ kyusyokusya.Field17__c : ' + kyusyokusya.Field17__c);
			System.debug(Logginglevel.WARN, '------ kyusyokusya.Field16__c=' + kyusyokusya.Field16__c);

            // 自動割当対象外、またはテストデータである、または★希望雇用形態が null であれば担当を割り振らない
            //テストが含まれている場合処理しない
			if (kyusyokusya.Name != null
				&& (
					kyusyokusya.Name.indexOf('テスト') != -1
					|| kyusyokusya.Name.indexOf('てすと') != -1
				)
			) {
				System.debug('------テストが含まれるため、処理を飛ばす------');
				continue;
			}
            //★希望雇用形態がnullの場合処理しない
            if (kyusyokusya.Field17__c == null){

				System.debug('------★希望雇用形態がnullの場合処理しない------');
            	continue;

            }

            // 希望職種から登録サイトを決定
            site = distributesSite(kyusyokusya);

            System.debug(Logginglevel.WARN, '***site=' + site);
            
            /*//dev
            // RJBかつ希望勤務地（第一希望）が入力されている場合
            if (site == 'PTOTJB' && String.isNotBlank(kyusyokusya.req_addr1__c)) {
            	
                List<CustomObject3__c> tantoAreaList = CustomObject3DAO.getTantoAreaList4MainArea(kyusyokusya.req_addr1__c, site);
System.debug('##tantoAreaList: ' + tantoAreaList);
                if (!tantoAreaList.isEmpty()) {

                	CustomObject3__c tantoArea = tantoAreaList.get(0);

                    //一致した求職者セット
                    addMatchKyusyokusyaMap.put(kyusyokusya.id, kyusyokusya);

                    //一致した担当エリアセット
                    matchTantouAreaMap.put(kyusyokusya.id, tantoArea);
                    
                    System.debug('##　RJBメインエリア適合; 求職者.id: ' +  kyusyokusya.id + ' 担当エリア表.Id: ' + tantoArea.Id);
                    continue;                	
                }

            }
            //end of dev*/

            // 住所を求める （PCと携帯で異なる）
            String addr = kyusyokusya.Field6__c;  // 都道府県

            //市区町村が空の場合
            if (kyusyokusya.Field7__c == null) {  // 携帯から手入力されたか？
                addr += kyusyokusya.Field21__c;   // + yes: 住所詳細（市区町村以下）を追加
            } else {
                addr += kyusyokusya.Field7__c;    // + no: 市区町村を追加
            }

            System.debug(Logginglevel.WARN, '>>>>>>address=' + addr);


            // 該当する都道府県と登録サイトの担当エリア表を取得-------------------------------------------------
            List<CustomObject3__c> tantouAeraList = getTantouAeraListCustom( kyusyokusya ,site);

            // 担当エリア表を元に常勤・非常勤によって、パターンと割り振り先(常勤/非常勤/メディア企画/非常勤メディア企画)を取得-------------------------------------------------

            System.debug( '>>>>>> tantouAeraList.size()=' + tantouAeraList.size());

			// 該当するエントリーなし
			//-------------------------------------------------------------------------

            if (tantouAeraList.size() == 0) {
            	System.debug( '--該当するエントリーなし、メール送信する----');

            	//登録連携ユーザor康祐さんに。メールでアラートを飛ばす

                //メール送信オブジェクト生成する
                SendMail__c mail = createSendMailForNotMatch(kyusyokusya,addr);
                sendmailList.add(mail);

            	//処理しない
            	continue;
            }

			// ----------------------------------------------------------------------------
            //担当エリア表と一致する住所を持つ求職者を絞り込む パターン1、2
			// ----------------------------------------------------------------------------

			Boolean matchFlag = false;

            for (CustomObject3__c tantouAera : tantouAeraList) {

                System.debug(Logginglevel.WARN, '>>>>>>loop1: key=' + tantouAera.key__c);

                //keyが空の場合処理を飛ばす
                if (tantouAera.key__c == null){
                	continue;
                }

				//住所が一致するかチェックする
                System.debug(Logginglevel.WARN, '>>>>>>tantouAera.key_special__c=' + tantouAera.key_special__c);
                System.debug(Logginglevel.WARN, '>>>>>>addr=' + addr);

				//パターン1：担当エリア：住所と求職者：住所が一致または、key(市を除いた区のみ)項目と一致した場合
                if(tantouAera.key__c == addr
                	|| (
                		tantouAera.key_special__c != null
                		&& tantouAera.key_special__c == addr
                	)
                ){

                    System.debug(Logginglevel.WARN, '>>>>>>match1');
                    System.debug(Logginglevel.WARN, '>>>>>>'+ tantouAera.id);

                    //一致した求職者セット
                    addMatchKyusyokusyaMap.put(kyusyokusya.id, kyusyokusya);

                    //一致した担当エリアセット
                    matchTantouAreaMap.put(kyusyokusya.id, tantouAera);

                    matchFlag = true;

                    //一致したら抜ける
                    break;
                }

                // パターン2：住所がkeyに前方一致するもので最も短いkeyを検索 （担当エリアkey=神奈川県横浜市, 求職者住所=神奈川県横浜のケース）
                if(tantouAera.key__c.contains(addr)
                	|| (
                		tantouAera.key_special__c != null
                		&& tantouAera.key_special__c.contains(addr)
                	)
                ) {
                    System.debug(Logginglevel.WARN, '>>>>>>match2');
                    System.debug(Logginglevel.WARN, '>>>>>>'+ tantouAera.id);

                    //一致した求職者セット
                    addMatchKyusyokusyaMap.put(kyusyokusya.id, kyusyokusya);

                    //一致した担当エリアセット
                    matchTantouAreaMap.put(kyusyokusya.id, tantouAera);

                    matchFlag = true;

                    //一致したら抜ける
                    break;
                }

            }

            if(!matchFlag){
                //一致していない場合、リストにつめ、別条件で判定する。
                addNotMatchKyusyokusyaMap.put(kyusyokusya.id, kyusyokusya);
            }

        }

        // 該当するエントリーガない求職者の情報を特定担当者に送信する。
        if(sendmailList.size() > 0){
        	insert sendmailList;
        }

        System.debug(Logginglevel.WARN, '--------一致した求職者');
        System.debug(Logginglevel.WARN, '--------addMatchKyusyokusyaMap.values.size()'+addMatchKyusyokusyaMap.values().size());
        System.debug(Logginglevel.WARN, '--------matchTantouAreaMap.values.size()'+matchTantouAreaMap.values().size());

    }

	/**
     * 担当エリア表と一致する住所を持つ求職者を絞り込む.
	 * パターン1,2に住所一致しない求職者
	 *
	 * @param addMatchKyusyokusyaMap 住所に一致した求職者Map
	 * @param addNotMatchKyusyokusyaMap 住所に一致しない求職者Map
	 * @param matchTantouAreaMap 住所に一致した担当エリアMap
	 * @param lastAddNotMatchKyusyokusyaList 住所が一致していない求職者
	 *
	 */
    @TestVisible private static void searchMatcheAddressSecond(
    	Map<String,CustomObject1__c> addMatchKyusyokusyaMap
    	,Map<String,CustomObject1__c> addNotMatchKyusyokusyaMap
    	,Map<String ,CustomObject3__c> matchTantouAreaMap
    	,List<CustomObject1__c> lastAddNotMatchKyusyokusyaList

    ){

		//登録サイト
        String site;

        for (CustomObject1__c kyusyokusya2: addNotMatchKyusyokusyaMap.values()) {

            // 希望職種から登録サイトを決定
            site = distributesSite(kyusyokusya2);

	        //担当エリア取得。キーが住所に前方一致するもので最も長いkeyを取得
			List<CustomObject3__c> tantouAeraDescList = getTantouAeraListCustomDesc( kyusyokusya2 ,site);

        	Boolean matchFlag = false;

            // 住所を求める （PCと携帯で異なる）
            String addr = kyusyokusya2.Field6__c;  // 都道府県
            
            system.debug('*** kyusyokusya2.Field6__c  ' + kyusyokusya2.Field6__c);
            system.debug('*** kyusyokusya2.Field7__c  ' + kyusyokusya2.Field7__c);
            
            //市区町村が空の場合
            if (kyusyokusya2.Field7__c == null) {  // 携帯から手入力されたか？
                addr += kyusyokusya2.Field21__c;   // + yes: 住所詳細（市区町村以下）を追加
            } else {
                addr += kyusyokusya2.Field7__c;    // + no: 市区町村を追加
            }

            if (addr != null) {

                for (CustomObject3__c tantouAeraDesc : tantouAeraDescList) {

                	matchFlag = false;

                    System.debug(Logginglevel.WARN, '>>>>>>loop3: key=' + tantouAeraDesc.key__c);

                    if (tantouAeraDesc.key__c == null)continue;

	                System.debug(Logginglevel.WARN, '>>>>>>tantouAeraDesc.key__c=' + tantouAeraDesc.key__c);
	                System.debug(Logginglevel.WARN, '>>>>>>tantouAeraDesc.key_special__c=' + tantouAeraDesc.key_special__c);
	                System.debug(Logginglevel.WARN, '>>>>>>addr=' + addr);

                    //パターン3： キーが住所に前方一致するもので最も長いkeyを検索 （key=神奈川県横浜市, 住所=神奈川県横浜市西区のケース）
                    if(addr.contains(tantouAeraDesc.key__c)
                    	|| (
                    		tantouAeraDesc.key_special__c != null
                    		&& addr.contains(tantouAeraDesc.key_special__c)
                    	)
                    ){

                    	System.debug(Logginglevel.WARN, '>>match3');
                    	System.debug(Logginglevel.WARN, '>>>>>>'+ tantouAeraDesc.id);

	                    //一致した求職者セット
                    	addMatchKyusyokusyaMap.put(kyusyokusya2.id, kyusyokusya2);

	                    //一致した担当エリアセット
	                    matchTantouAreaMap.put(kyusyokusya2.id, tantouAeraDesc);

	                    matchFlag = true;
	                    //一致したら抜ける
	                    break;
                    }

                }
            }

            // 住所がマッチしない場合の担当者の設定
			// ----------------------------------------------------------------------------
            //一致していない場合
            if(!matchFlag){

            	//登録連携ユーザor康祐さんに割り振り。メールでアラートを飛ばす

            	System.debug(Logginglevel.WARN, '>>>>>>match4>>住所がマッチしない場合');

                //どの住所にも一致しない求職者
                lastAddNotMatchKyusyokusyaList.add(kyusyokusya2);
            }
   		}
    }

    /**
     * 所有者が設定された求職者の所有者にメール送信するため、アドレスを取得する
     * 担当エリアから設定された用
     * メール送信作成 //afterでメール送信するためコメントアウト
     *
     * @param kyusyokusyaList 求職者リスト
     * @param trgetTantouAreaMap 所有者を設定したときの担当エリアオブジェクト
     *
     */
    public static Map<String, List<String>> getSendTargetAddress(
    	List<CustomObject1__c> kyusyokusyaList
    	, Map<String, CustomObject3__c> trgetTantouAreaMap
    ) {

		System.debug('----所有者が設定された求職者の所有者にメール送信するため、アドレスを取得する---');

		Map<String, List<String>> userListForTantouArea = new Map<String, List<String>>();

		//求職者keyに担当エリアのその他アドレスに送信
    	for(CustomObject1__c kyusyokusya : kyusyokusyaList){

    		//キーはcustomer_id__cを使用する
    		//CustomObject3__c trgetTantouArea = trgetTantouAreaMap.get(kyusyokusya.id);
    		CustomObject3__c trgetTantouArea = trgetTantouAreaMap.get(kyusyokusya.customer_id__c);

    		if(trgetTantouArea != null){

    			//その他メール
    			String otherEmail = trgetTantouArea.OthersSendAddress__c;

    			if(otherEmail != null){
    				//「;」区切りでメールアドレスが入力されている
    				List<String> eMailAddress = otherEmail.split(';');

					List<String> emailadds = new List<String>();

    				for(String address : eMailAddress){

						System.debug('----address---'+ address);
			    		//送信先保持
			    		emailadds.add(address);
    				}

    				//keyはユニーク項目 求職者単位で送信先を保持
    				userListForTantouArea.put(kyusyokusya.customer_id__c, emailadds);
    			}
    		}
    	}

		System.debug('----担当エリアのその他アドレスに送信--userListForTantouArea-'+userListForTantouArea);

		return userListForTantouArea;
    }


    /**
     * 所有者が設定された求職者の所有者を特定する
     * キューの場合は、キューに含まれるユーザを取得
     *
     *  メール送信はafter triggerで行う
     */
    public static Map<String, List<User>> getUserForOwnerId(List<CustomObject1__c> kyusyokusyaList) {

		System.debug('---所有者が設定された求職者の所有者を特定する---');

		//対象がない場合は処理なし
		if(kyusyokusyaList == null || kyusyokusyaList.size() == 0){
				return null;
		}

    	Map<String, List<User>> userListMap = new Map<String, List<User>>();

		System.debug('----sencEmail---'+ kyusyokusyaList.size());

      	//メールと携帯メール送信の両方が送信不可のユーザは除く.ユーザ取得 ゆくゆくは関連必要なユーザのみを取得
    	Map<Id,User> userMap = getUserMap();

		//userのプレフィックス取得
		String userPrefix = Schema.getGlobalDescribe().get('User').getDescribe().getKeyPrefix();
		System.debug('---userのプレフィックス取得---' + userPrefix);

		//求職者の所有者のリストを保持。キューの場合は関連するユーザ
		Map<String,Set<Id>> kyusyokusyaUserMap = new Map<String,Set<Id>>();

    	//所有者取得 キューからユーザを取得する方法の改善はあとから。ガバナ制限に引っかかる可能性があるが複数件の、
    	for(CustomObject1__c kyusyokusya: kyusyokusyaList){

    		//所有者
    		String ownerId = kyusyokusya.OwnerId;

			System.debug('----ownerId---' + ownerId);
			System.debug('----kyusyokusya.customer_id__c---' + kyusyokusya.customer_id__c);

			//シリアル（システムキー用）がある場合
			if(kyusyokusya.customer_id__c != null){

	    		//プレフィックスから判定
	    		//ユーザの場合
	    		if(userPrefix == ownerId.substring(0, 3)){
					System.debug('----所有者ユーザの場合---' + ownerId);
	    			//kyusyokusyaUserMap.put(kyusyokusya.id, new Set<Id>{ownerId});
	    			kyusyokusyaUserMap.put(kyusyokusya.customer_id__c, new Set<Id>{ownerId});

	    		//キュの場合
	    		}else{
					System.debug('----所有者キュの場合---' + ownerId);

	    			//キューからユーザを取得
	    			Set<Id> userListForQueue = getUserListForQueue(ownerId);
	    			//kyusyokusyaUserMap.put(kyusyokusya.id, userListForQueue);
	    			kyusyokusyaUserMap.put(kyusyokusya.customer_id__c, userListForQueue);

	    		}
			}

    	}
        
        system.debug(' *** kyusyokusyaList *** ' + kyusyokusyaList);
        
		//求職者単位メールを作成する
    	for(CustomObject1__c kyusyokusya: kyusyokusyaList){

			List<User> userList = new List<User>();

			//シリアル（システムキー用）がある場合
			if(kyusyokusya.customer_id__c != null){

	    		//送信対象ユーザ
	    		//Set<Id> reUserIds = kyusyokusyaUserMap.get(kyusyokusya.id);
	    		Set<Id> reUserIds = kyusyokusyaUserMap.get(kyusyokusya.customer_id__c);
				System.debug('----送信対象ユーザ---' + reUserIds.size());

	    		for(Id uId : reUserIds){

	    			//ユーザ情報取得
	    			User uObj = userMap.get(uId);
                    system.debug('*** userMap *** ' + userMap);
                    system.debug('*** uObj *** ' + uObj);
                    system.debug('*** uId *** ' + uId);
                    
	    			if(uObj != null){
	    				userList.add(uObj);
	    			}
	    		}

				System.debug('----userList---' + userList);
	    		//求職者idをキーに送信するユーザを保持する  customer_id__c
	    		//userListMap.put(kyusyokusya.id, userList);
	    		userListMap.put(kyusyokusya.customer_id__c, userList);
			}
    	}
        
    	return userListMap;

    }

    /**
     * キュ-idから関連するユーザを取得
     * 下位ロール場合は、下位ロールは見ない。ロールのみ。公開グループは今回対象外。
     *
     * キューに含まれる、ユーザとロールに含まれるユーザが対象。
     *
     */
    public static Set<id> getUserListForQueue(String queueId){

		//キューidからメンバーを取得。ユーザとロールが対象
		List<GroupMember> gMenberlist = [Select UserOrGroupId, Id, GroupId From GroupMember where  GroupId=:queueId];

		Set<String> targetid = new Set<String>();

		//メンバ
		for(GroupMember gMenber: gMenberlist){
			System.debug('--gMenber---'+gMenber);
			//ユーザとグループidが取得。ユーザidが含まれるが、プレフィックスが違うためGroup取得に影響ない。
			targetid.add(gMenber.UserOrGroupId);
		}

		//UserOrGroupIdからユーザ取得
		//mod_start_2015/05/28 ogino #4915
		//List<User> ulist0 = [select id from User where id=:targetid];
		List<User> ulist0 = [select id,IsActive from User where id=:targetid];
		//mod_end_2015/05/28 ogino #4915

		//ユーザidを保持
		Set<id> uset = new Set<id>();

		for(User u: ulist0){
			System.debug('-----'+u);
			//addAllをつづけてやるとエラーが出るため、addをしようする。ユーザidを保持
			uset.add(u.id);
		}

		//UserOrGroupIdからグループを取得
		//ロール、下位ロール取得。公開グループは今回対象外。公開グループはキューと同じメンバをもつ。さらにqueryが必要
		List<Group> queueList = [Select Type, RelatedId,Name, Id, Email, DeveloperName From Group WHERE  id=:targetid];

		//RelatedIdがロールid。保持
		Set<String> relatedIds = new Set<String>();

		for(Group g: queueList){
			System.debug('---g--'+g);
			//リレーションID取得。ロールIdにあたる。
			relatedIds.add(g.RelatedId);
		}

		//ロールから関連ユーザ取得
		//mod_start_2015/05/28 ogino #4915
		//List<User> ulist = [select id,UserRoleId from User where UserRoleId=:relatedIds];
		List<User> ulist = [select id,UserRoleId,IsActive from User where UserRoleId=:relatedIds];
		//mod_end_2015/05/28 ogino #4915
		for(User u: ulist){
			System.debug('-----'+u);
			//ユーザidを保持
			uset.add(u.id);
		}

		return uset;
    }

    /**
     * メール送信オブジェクト生成。
     * 担当エリアに一致しない場合用
     *
     */
    //private static SendMail__c createSendMail(CustomObject1__c kyusyokusya, String addr){
    public static SendMail__c createSendMailForNotMatch(CustomObject1__c kyusyokusya, String addr){

		//ホスト名
		String hostName = URL.getSalesforceBaseUrl().getHost();
		//プロトコル名
		String protocolName = URL.getSalesforceBaseUrl().getProtocol();
		String urlStr = protocolName + '://'+hostName + '/' + kyusyokusya.id;

		System.debug('----protocolName---'+protocolName);
		System.debug('----hostName---'+hostName);

        //メール送信オブジェクト生成する
        SendMail__c mail = new SendMail__c();
        //機能 [所有者変更処理]を設定
        mail.FunctionCategory__c = FUNCTIONCATEGORY_VALUE;
        //送信方法
        mail.SendMethod__c = '単体メール';
        //NJB/RJB/CJB区分
        mail.Category__c = kyusyokusya.njb_rjb_cjb_flag__c;

        //件名
        mail.Subject__c =' 担当エリア表にマッチするレコードがありません。または、担当者キュー存在しません。';

        //本文
        String body = '担当エリア表にマッチするレコードがありません。\nまたは、担当者キュー存在しません。\n';
        body += '求職者ID：' + kyusyokusya.id + '\n';
        body += '求職者名：' + kyusyokusya.name + '\n';
        body += '住所：' + addr + '\n';
        body += 'url：' + urlStr + '\n';
        body += '\n\n';

        mail.Body__c = body;

        //宛先メールアドレス1
        //mail.ToMailAddress1__c = userObj.Email;
        //mail.ToMailAddress1__c = 'ryosuke-imaizumi@bm-sms.co.jp';
        //mail.ToMailAddress2__c = 'kosuke-suzuki@bm-sms.co.jp';
        //mail.ToMailAddress2__c = 'yutaka-nomura@bm-sms.co.jp'; //2014/10/01 daidouzi add #3512

        //del_start_2015/11/09 ogino #7949
        //mail.ToMailAddress1__c = address1Value;
        //mail.ToMailAddress2__c = address2Value;
        //del_end_2015/11/09 ogino #7949
        
        //add_start_2015/11/09 ogino #7949
        mail.ToMailAddress1__c = System.Label.SET_REQ_OWNER_ERROR_ADDRESS_COMMON;
        if(kyusyokusya.njb_rjb_cjb_flag__c == 'NJB'){
            mail.ToMailAddress2__c = System.Label.SET_REQ_OWNER_ERROR_ADDRESS_NJB;
        }
        if(kyusyokusya.njb_rjb_cjb_flag__c == 'CJB'){
            mail.ToMailAddress2__c = System.Label.SET_REQ_OWNER_ERROR_ADDRESS_CJB;
        }
        if(kyusyokusya.njb_rjb_cjb_flag__c == 'RJB'){
            mail.ToMailAddress2__c = System.Label.SET_REQ_OWNER_ERROR_ADDRESS_RJB;
        }
        //add_end_2015/11/09 ogino #7949
        return mail;

    }

    /**
     * メール送信オブジェクト生成。
     * userのメール送信不可フラグを判定する
     *
     */
    public static SendMail__c createSendMailForOwner(EmailTemplate templateObj, CustomObject1__c kyusyokusya, User userObj){

    	String email = null;
    	String mobileMail = null;

        //PCメール送信 送信不可フラグがoffの場合
        if(!userObj.NotSendMail__c){
	        email = userObj.Email;
        }
        //携帯メール送信 送信不可フラグがoffの場合
        if(!userObj.NotSendmoMobileMail__c){
        	mobileMail = userObj.mobile_mail__c;
        }
        
        //add_start_2015/05/28 ogino #4915 ユーザが無効の場合は障害通知メールを送信する
        if(!userObj.IsActive){
            return createAlertMail(templateObj,kyusyokusya,userObj);
        }

        //メール送信オ
        return createSendMailForOwner(templateObj, kyusyokusya, email, mobileMail);
    }

    /**
     * メール送信オブジェクト生成。
     *
     */
    public static SendMail__c createSendMailForOwner(EmailTemplate templateObj, CustomObject1__c kyusyokusya, String email, String mobileMail){

		System.debug('----createSendMailForOwner---');
		System.debug('----email---' + email);
		System.debug('----mobileMail---' + mobileMail);

		//本文置換
		String bodyStr = replaceByRecordVal(kyusyokusya, templateObj.Body);
		//件名置換
		String subjectStr = replaceByRecordVal(kyusyokusya, templateObj.Subject);

		System.debug('----subjectStr---'+subjectStr);
		System.debug('----bodyStr---'+bodyStr);

        //メール送信オブジェクト生成する
        SendMail__c mail = new SendMail__c();
        //機能 [所有者変更処理]を設定
        mail.FunctionCategory__c = FUNCTIONCATEGORY_VALUE;
        //送信方法
        mail.SendMethod__c = '単体メール';
        //NJB/RJB/CJB区分
        mail.Category__c = kyusyokusya.njb_rjb_cjb_flag__c;

        //件名
        mail.Subject__c =subjectStr;
        //本文
        mail.Body__c = bodyStr;

        //宛先メールアドレス1
	     mail.ToMailAddress1__c = email;
        //宛先メールアドレス2
        mail.ToMailAddress2__c = mobileMail;

        return mail;

    }

    /**
     * {!Account.id}形式の文字列を取得し、SObjectの項目の値と置き換える。
     * 置き換わる項目はqueryに含まれていること。
     * 置換対象のオブジェクトは1つのみ。複数含まれる場合は対象ののオブジェクト以外は、空文字で置換
     */
    public static String replaceByRecordVal(SObject sObj, String target) {

		System.debug('----replaceByRecordVal---');

        String replaceString = target;
        if (replaceString==null)replaceString='';

		try{

	        //パターン設定
	        Pattern myPattern = Pattern.compile('\\{![a-zA-Z]{1}[0-9a-zA-Z._]*\\}');
	        Matcher matcher = myPattern.matcher(replaceString);

	        boolean isErr = false;

	        //パターンに一致する文字列分ループ
	        while (matcher.find()) {
	        	//置換対象の項目のapi名。{!AAA.BB__c}のBB__cの部分
	        	String value = matcher.group();
	        	//置換後に入る値。
	            String strValue = '';
	            //オブジェクト名。{!AAA.BB__c}のAAAの部分
	            String key = null;
	            Boolean blnFlg = false;
	            //「{!」「}」を除く
	            value = value.substring(2, value.length()-1);

	            Integer index = value.indexOf('.');
	            if(index > -1){
	            	//オブジェクト名
	                key = value.substring(0, index);
	                //項目名
	                value = value.substring(index + 1);
	                blnFlg = true;
	            }

				//System.debug('----key---'+key);
				//System.debug('----value---'+ value);

	            //求職者レコード
	            if (sObj != null) {

	            	//オブジェクトのapi名
		            String sObjectName = sObj.getSObjectType().getDescribe().getName();
					//System.debug('----sObjectName---'+sObjectName);

	                try{

						//置換するオブジェクトと{!aaa.aa__c}のオブジェクトが一致する場合
						if(sObjectName == key){

		                    Object tmpValue = null;

			                //特定の項目の処理。項目がOwnerFullNameの場合。OwnerFullNameはメールテンプレート専用の項目。
			                if(value == 'OwnerFullName'){

			                	//所有者の名前を取得
			                	tmpValue = sObj.getSobject('Owner').get('Name');
			                	strValue = String.valueOf(tmpValue);

			                //通常の項目の場合。上記以外の場合
			                }else{

			                	//項目から取得した値
			                    tmpValue = sObj.get(value);

			                    //項目の型によってフォーマットする
			                    if (tmpValue != null) {
			                        if (tmpValue instanceof Date) {
			                            strValue = ((Date)tmpValue).format();
			                        } else if (tmpValue instanceof DateTime) {
			                            strValue = ((DateTime)tmpValue).format();
			                        } else if (tmpValue instanceof Decimal) {
			                            strValue = ((Decimal)tmpValue).format();
			                        } else {
			                            strValue = String.valueOf(tmpValue);
			                        }
			                    } else {
			                        strValue = '';
			                    }
			                }

						}else{
							System.debug('----置換するオブジェクトと一致しない---'+sObjectName);
	                        strValue = '';
						}

	                }catch(Exception e){
	                		System.debug('---Exception---'+e);
	                		System.debug('---項目がない---'+value);
	                        strValue = '';
	                }
	            }

	            //{!AAA.BB__c}のタイプの場合
	            if (blnFlg) {
	                //置換
	                replaceString = replaceString.replaceAll('\\{!' + key + '.' + value + '\\}', strValue);

	            //{!AAA}のタイプの場合
	            } else {
	            	//置換
	                replaceString = replaceString.replaceAll('\\{!' + value + '\\}', strValue);
	            }
	        }
		}catch(Exception e){
			System.debug('----置換処理Exception--' + e.getMessage());
			System.debug('------' + e.getStackTraceString());

			//エラーの場合は置換せずそのまま。
			replaceString = target;
		}

        return replaceString;
    }


	/**
	 * 割り振り処理。所有者にメール送信
	 *
	 *
	 */
	public static void sendForAllocation(Map<String, List<User>> userListForAllocation){

    	//メールテンプレート取得
		EmailTemplate templateObj = EmailTemplateDao.getEmailTemplate('EmailTemplate_test');
		//add_start_2015/05/22 ogino #5667
		EmailTemplate templateObjCRJB = EmailTemplateDao.getEmailTemplate('EmailTemplate_nonmedia');
		//add_end_2015/05/22 ogino #5667

		if(userListForAllocation != null){
			//送信対象のメール送信
			List<SendMail__c> sendMailList = new List<SendMail__c>();

			System.debug('---------------割り振り処理。所有者にメール送信---');

			//求職者取得 keyは求職者のcustomer_id__c
			Set<String> keySet = userListForAllocation.keySet();

			Map<String, CustomObject1__c> kyusyokusyaMap = new Map<String, CustomObject1__c>();

			//送信対象の求職者を取得する。id、自動採番項目を取得するため。
			List<CustomObject1__c> kyuList = getKyusyokusyaListForCustomerId(keySet);

			for(CustomObject1__c kObj: kyuList){
				kyusyokusyaMap.put(kObj.customer_id__c, kObj);
			}

			//求職者単位メールを作成する
	    	for(String key: userListForAllocation.keySet()){

	    		//送信ユーザ取得
	    		List<User> uList = userListForAllocation.get(key);
	    		//求職者取得
	    		CustomObject1__c kyusyokusya = kyusyokusyaMap.get(key);
	    		//add_start_2015/05/28 ogino #4915
	    		if(kyusyokusya == null){
                    System.debug('_/_/_/_/_/key:'+key);
	    		    System.debug('_/_/_/_/_/kyusyokusyaMap:'+kyusyokusyaMap);
	    		    System.debug('_/_/_/_/_/userListForAllocation:'+userListForAllocation);
	    		     SendMail__c sendMail = createJobSeekerEmptyMail(key,kyusyokusyaMap,userListForAllocation);
	    		     sendMailList.add(sendMail);
	    		     continue;
	    		}
	    		//add_end_2015/05/28 ogino #4915
				System.debug('----送信対象ユーザ---' + uList.size());

	    		for(User uObj : uList){

	    			System.debug('----送信対象ユーザ---' + uObj.id);

		    		//メール送信作成
		    		//mod_start_2015/05/22 ogino #5667
		    		//SendMail__c sendMail = SetReqOwnerCustom.createSendMailForOwner(templateObj, kyusyokusya, uObj);
		    		//sendMailList.add(sendMail);
		    		if(kyusyokusya.njb_rjb_cjb_flag__c == 'NJB'){
		    		    System.debug('_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/NJB');
		    		    SendMail__c sendMail = SetReqOwnerCustom.createSendMailForOwner(templateObj, kyusyokusya, uObj);
		    		    sendMailList.add(sendMail);
		    		}else{
                        System.debug('_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/CRJB');
                        SendMail__c sendMail = SetReqOwnerCustom.createSendMailForOwner(templateObjCRJB, kyusyokusya, uObj);
                        sendMailList.add(sendMail);
		    		}
		    		//mod_end_2015/05/22 ogino #5667
	    		}
	    	}

	    	if(sendMailList.size() > 0){
	    		insert sendMailList;
	    	}
		}
	}

	/**
	 * 担当エリア その他アドレス割り振りにメール
	 *
	 *
	 */
	public static void sendForForTantouArea(Map<String, List<String>> userListForTantouArea){

		if(userListForTantouArea != null){
	    	//メールテンプレート取得
			EmailTemplate templateObj = EmailTemplateDao.getEmailTemplate('EmailTemplate_test');
            //add_start_2015/05/22 ogino #5667
            EmailTemplate templateObjCRJB = EmailTemplateDao.getEmailTemplate('EmailTemplate_nonmedia');
            //add_end_2015/05/22 ogino #5667

			System.debug('----------------担当エリア その他アドレスにメール送信---');

			//送信対象のメール送信
			List<SendMail__c> sendMailList = new List<SendMail__c>();

			//求職者取得
			Set<String> keySet = userListForTantouArea.keySet();

			//customer_id__cをキーに求職者を保持する
			Map<String, CustomObject1__c> kyusyokusyaMap = new Map<String, CustomObject1__c>();

			//送信対象の求職者を取得する。id、自動採番項目を取得するため。
			List<CustomObject1__c> kyuList = getKyusyokusyaListForCustomerId(keySet);

			for(CustomObject1__c kObj: kyuList){
				kyusyokusyaMap.put(kObj.customer_id__c, kObj);
			}

			//求職者単位メールを作成する
	    	for(String key: userListForTantouArea.keySet()){

	    		//求職者取得 キーはcustomer_id__cを使用する
	    		CustomObject1__c kyusyokusya = kyusyokusyaMap.get(key);
	    		//送信対象リスト
	    		List<String> adds =  userListForTantouArea.get(key);

	    		if(kyusyokusya != null){

    				for(String emailAddress : adds){

						System.debug('----emailAddress---'+ emailAddress);
			    		//メール送信作成
			    		//mod_start_2015/05/22 ogino #5667
			    		//SendMail__c sendMail = SetReqOwnerCustom.createSendMailForOwner(templateObj, kyusyokusya, emailAddress, null);
			    		//sendMailList.add(sendMail);
			    		if(kyusyokusya.njb_rjb_cjb_flag__c == 'NJB'){
                            SendMail__c sendMail = SetReqOwnerCustom.createSendMailForOwner(templateObj, kyusyokusya, emailAddress, null);
                            sendMailList.add(sendMail);
			    		}else{
                            SendMail__c sendMail = SetReqOwnerCustom.createSendMailForOwner(templateObjCRJB, kyusyokusya, emailAddress, null);
                            sendMailList.add(sendMail);
			    		}
			    		//mod_end_2015/05/21 ogino #5667
    				}
	    		}
	    	}

	    	if(sendMailList.size() > 0){
	    		insert sendMailList;
	    	}
		}
	}


	/**
	 * 対象のユーザにメールを送信する
	 * after insert  after update
	 * //2015/3/6 daidouzi add #4634
	 *
	 */
	public static void sendMailAll(){

		//対象のユーザにメールを送信する

		System.debug('---対象のユーザにメールを送信する---' );

		//割り振り、担当者あり宛、その他の割り振りロジック。 beforeで設定した情報を取得
		Map<String, List<User>> userListForAllocation = Utility.getUserListForAllocation();
		//割り振りエラー
		List<CustomObject1__c> userListForAllocationErroe = Utility.getUserListForAllocationErroe();
		//担当エリア その他アドレス割り振り
			Map<String, List<String>> userListForTantouArea = Utility.getUserListForTantouArea();
		//担当エリア割り振り対象外
		List<CustomObject1__c> userListForTantouAreaError = Utility.getUserListForTantouAreaError();

		System.debug('---userListForAllocation---' + userListForAllocation);
		System.debug('---userListForAllocationErroe---' + userListForAllocationErroe);
		System.debug('---userListForTantouArea---' + userListForTantouArea);
		System.debug('---userListForTantouAreaError---' + userListForTantouAreaError);

		//送信処理を行ったらクリアする
		Utility.setUserListForAllocation(null);
		//割り振りエラー
		Utility.setUserListForAllocationErroe(null);
		//担当エリア その他アドレス割り振り
		Utility.setUserListForTantouArea(null);
		//担当エリア割り振り対象外
		Utility.setUserListForTantouAreaError(null);

		//------------------------------------------------------------------------------------------------------------
		//割り振り処理。所有者にメール送信----------------
		//------------------------------------------------------------------------------------------------------------
		SetReqOwnerCustom.sendForAllocation(userListForAllocation);

		//------------------------------------------------------------------------------------------------------------
		//割り振り処理　エラーの場合。所有者にメール送信----------------
		//------------------------------------------------------------------------------------------------------------
		if(userListForAllocationErroe != null){
			System.debug('----------------割り振り処理　エラーの場合。所有者にメール送信-------'+ userListForAllocationErroe);
			//エラーが発生した求職者にたいして特定の人にメールでアラートを飛ばす
   			SetReqOwnerCustom.sendMailForNotMatch(userListForAllocationErroe);
		}

		//------------------------------------------------------------------------------------------------------------
		//担当エリア その他アドレス割り振り
		//------------------------------------------------------------------------------------------------------------
		SetReqOwnerCustom.sendForForTantouArea(userListForTantouArea);

		//------------------------------------------------------------------------------------------------------------
		//担当エリア 該当なしの場合。特定のユーザにメール
		//------------------------------------------------------------------------------------------------------------
		if(userListForTantouAreaError != null){

			System.debug('----------------担当エリア 該当なしの場合。特定のユーザにメール-------');
			//エラーが発生した求職者にたいして特定の人にメールでアラートを飛ばす
   			SetReqOwnerCustom.sendMailForNotMatch(userListForTantouAreaError);
		}
		//add_start_2015/05/28 ogino #4915
		if(getErrChangeOwnerJobSeekerDtoList() != null){
          Map<Id,List<JobSeekerDto>> checkOwnerSetJobSeekerDtoListMap = new Map<Id,List<JobSeekerDto>>();
          for(JobSeekerDto jobSeekerDto:getErrChangeOwnerJobSeekerDtoList()){
              //メール配信除外キューの場合は、送信しない
              if(jobSeekerDto.jobSeeker.OwnerId == getNotSendEmailGroupId()){
                continue;
              }
              //NotMatchでメール送信している場合は送信していない場合
              if(getNotMatchJobSeekerMap().get(jobSeekerDto.jobSeeker.Id) == null){
                    if(checkOwnerSetJobSeekerDtoListMap.get(jobSeekerDto.jobSeeker.Id) != null){
                        checkOwnerSetJobSeekerDtoListMap.get(jobSeekerDto.jobSeeker.Id).add(jobSeekerDto);
                    }else{
                        List<JobSeekerDto> jobSeekerDtoList = new List<JobSeekerDto>();
                        checkOwnerSetJobSeekerDtoListMap.put(jobSeekerDto.jobSeeker.Id,jobSeekerDtoList);
                        checkOwnerSetJobSeekerDtoListMap.get(jobSeekerDto.jobSeeker.Id).add(jobSeekerDto);
                    }
              }
          }
		  
		  List<SendMail__c> sendMailList = new List<SendMail__c>();
		  for(List<JobSeekerDto> jobSeekerDtoList:checkOwnerSetJobSeekerDtoListMap.values()){
		      
		      String debugMsg = '';
		      JobSeekerDto mailJobSeekerDto = null;
		      for(JobSeekerDto jobSeekerDto:jobSeekerDtoList){
		          if(jobSeekerDto.ownerSetFlag){
		              debugMsg = '';
                      mailJobSeekerDto = null;
		              break;
		          }else{
		              debugMsg += jobSeekerDto.debugMsg;
		              mailJobSeekerDto = jobSeekerDto;
		          }
		      }
		      
		      if(String.isNotBlank(debugMsg) && mailJobSeekerDto != null){
		        mailJobSeekerDto.debugMsg = debugMsg;
                SendMail__c mail = createErrMailChangeOwner(mailJobSeekerDto);
                sendMailList.add(mail);
		      }
		  }
		  //他の機能のテストクラスでエラーが発生するため、テストのときは実行しない
		  if(!Test.isRunningTest()){
		      insert sendMailList;
		  }
		  errChangeOwnerJobSeekerDtoList = null;
		  NotMatchJobSeekerMap = null;
		}
		//add_end_2015/05/28 ogino #4915
	}

	/**
	 * customer_id__cから求職者を取得する
	 * メール送信で使用する項目を定義する。
	 * customer_id__cはkeyになるため必要
	 *
	 */
	@TestVisible private static List<CustomObject1__c> getKyusyokusyaListForCustomerId(Set<String> keySet){

		List<CustomObject1__c> kyuList = [
			select
				Id
				,customer_id__c
				,StateEdit__c
				,CityEdit__c
				,SF_number__c
				,entry_category__c
				,Field3__c
				,Field413__c
				,Field411__c
				,Field14__c
				,Field124__c
				,retirement_intention__c
				,Field144__c
				,njb_rjb_cjb_flag__c
				,Field348__c
				,Field347__c
				,OwnerId
				,Owner.Name //user と キュー共通
				, Field145__c   //登録オススメ求人  2015/10/05 yoshinaga add #7391
                ,Field417__c    //add_start_2016/04/26 MATCHING_PROMOTION_SYSTEM-2565
			from CustomObject1__c
			where
				customer_id__c =: keySet
		];

		return kyuList;

	}

	/**
	 * //メールと携帯メール送信の両方が送信不可のユーザは除く.
	 *
	 */
	//2015/04/01 yoshinaga update start
	//private static Map<Id,User> getUserMap(){
	public static Map<Id,User> getUserMap(){
	///2015/04/01 yoshinaga update end

      	//メールと携帯メール送信の両方が送信不可のユーザは除く
    	Map<Id,User> userMap = new Map<Id,User>([
    		select
    			id, Name, Email, mobile_mail__c, NotSendMail__c, NotSendmoMobileMail__c
    			//add_start_2015/05/28 ogino #4915
    			,IsActive
    			//add_end_2015/05/28 ogino #4915
    		from
    			User
    		where
    			not (NotSendMail__c = true
    				and NotSendmoMobileMail__c = true
    			)
    	]);

    	return userMap;
	}

//add_start_2015/05/28 ogino #4915
    /**
     * 警告メールを生成する
     */
    public static SendMail__c createAlertMail(EmailTemplate templateObj, CustomObject1__c kyusyokusya, User userObj){
        
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        
            //メール送信オブジェクト生成する
            SendMail__c mail = new SendMail__c();
            //機能 [障害通知]を設定
                mail.FunctionCategory__c = '警告通知';
            //送信方法
            mail.SendMethod__c = '単体メール';
            //NJB/RJB/CJB区分
            mail.Category__c = kyusyokusya.njb_rjb_cjb_flag__c;
            
            //件名
            mail.Subject__c = '通知先のユーザが無効です。';
            
            String bodyStr = '次のユーザは無効になっています。';
            bodyStr += '\r\n';
            bodyStr += 'ユーザ名：';
            bodyStr += userObj.Name;
            bodyStr += '\r\n';
            bodyStr += baseURL;
            bodyStr += '/';
            bodyStr += userObj.Id;
            bodyStr += '\r\n\r\n';
            
            bodyStr += '次の求職者に関してメール送信される予定でした。';
            bodyStr +='\r\n';
            bodyStr += baseURL;
            bodyStr += '/';
            bodyStr += kyusyokusya.Id;
            bodyStr += '\r\n\r\n';
            
            //本文
            mail.Body__c = bodyStr;
            
            if(kyusyokusya.njb_rjb_cjb_flag__c == 'NJB'){
                
                //宛先メールアドレス1
                mail.ToMailAddress1__c = 'ml.sf-helpdesk@bm-sms.co.jp';
            }else{
                
                //宛先メールアドレス1
                mail.ToMailAddress1__c = 'co-medical-system@jinzaibank.mobi';
            }
            
            //宛先メールアドレス2
            mail.ToMailAddress2__c = System.Label.ErrInfoMailAddress1;
            
            return mail;
    }
    
    /**
     * 求職者がnullの場合の例外処理
     */
    public static SendMail__c createJobSeekerEmptyMail(String key,Map<String,CustomObject1__c> kyusyokusyaMap,Map<String, List<User>> userListForAllocation){
        
        SendMail__c mail = new SendMail__c();
        //機能 [障害通知]を設定
        mail.FunctionCategory__c = '障害通知';
        //送信方法
        mail.SendMethod__c = '単体メール';
        
        mail.Category__c = '障害';
            
        mail.Subject__c = '求職者がnullのためメール送信できませんでした。';
        
        String bodyStr = '';
        bodyStr += '_/_/_/_/_/key:';
        bodyStr += 'key';
        bodyStr += '\r\n';
        
        if(kyusyokusyaMap != null && !kyusyokusyaMap.isEmpty()){
            
            bodyStr += '_/_/_/_/_/kyusyokusyaMap.size():' + kyusyokusyaMap.size();
            bodyStr += '\r\n';
            bodyStr += '_/_/_/_/_/kyusyokusyaMap.get(key):' + kyusyokusyaMap.get(key);
            bodyStr += '\r\n';
        }
        
        if(userListForAllocation != null && !userListForAllocation.isEmpty()){
            bodyStr += '_/_/_/_/_/userListForAllocation.size():' + userListForAllocation.size();
            bodyStr += '\r\n';
            bodyStr += '_/_/_/_/_/userListForAllocation.get(key):' + userListForAllocation.get(key);
            bodyStr += '\r\n';
        }
        
        
            //本文
            mail.Body__c = bodyStr;
            
            //宛先メールアドレス1
            mail.ToMailAddress1__c = System.Label.ErrInfoMailAddress1;
            //宛先メールアドレス2
            mail.ToMailAddress2__c = System.Label.ErrInfoMailAddress2;
        
        return mail;
    }
    /**
     * 所有変更時のIDが無効の場合にメール送信する
     */
    public static SendMail__c createErrMailChangeOwner(JobSeekerDto jobSeekerDto){
        
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        
        CustomObject1__c kyusyokusya = jobSeekerDto.jobSeeker;
        
        //メール送信オブジェクト生成する
        SendMail__c mail = new SendMail__c();
        //機能 [障害通知]を設定
        mail.FunctionCategory__c = '警告通知';
        //送信方法
        mail.SendMethod__c = '単体メール';
        //NJB/RJB/CJB区分
        mail.Category__c = kyusyokusya.njb_rjb_cjb_flag__c;
        
        //件名
        mail.Subject__c = 'IDが不正なため、求職者の所有者を変更できませんでした。';
        
        String bodyStr = '';
        
        bodyStr += '次の求職者に関して所有者を変更できませんでした。';
        bodyStr +='\r\n';
        bodyStr += baseURL;
        bodyStr += '/';
        bodyStr += kyusyokusya.Id;
        bodyStr += '\r\n\r\n';
        
        bodyStr += jobSeekerDto.debugMsg;
        
        //本文
        mail.Body__c = bodyStr;
        
        if(kyusyokusya.njb_rjb_cjb_flag__c == 'NJB'){
            
            //宛先メールアドレス1
            mail.ToMailAddress1__c = 'ml.sf-helpdesk@bm-sms.co.jp';
        }else{
            
            //宛先メールアドレス1
            mail.ToMailAddress1__c = 'co-medical-system@jinzaibank.mobi';
        }
        
        //宛先メールアドレス2
        mail.ToMailAddress2__c = System.Label.ErrInfoMailAddress1;
        
        return mail;
    }
//add_end_2015/05/28 ogino #4915

    /*
    public static List<CustomObject1__c> setOwnerForKyusyokuIdAndAction(CustomObject1__c[] co, Map<id, CustomObject1__c> coOldMap) {

        System.debug(Logginglevel.WARN, '-------setOwnerForKyusyokuIdAndAction:'+co.size());

        //看護学生用ユーザ、商品設計チーム共通アカウント取得
        User kgOwner = [select id, Email from User where Username like 'marketingtool-njb@bm-sms.co.jp%' limit 1];
        //希望職種：その他自動振り分け（単独選択時）、山田 宏行アカウント取得
        User otherOwner = [select id, Email from User where Username like 'hiroyuki-yamada@bm-sms.co.jp%' limit 1];

		//RJB学生専用を取得する
        List<Group> rjbGkusei = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'RJB_student'];


		//キューを取得する
		//2014/8/1 daidouzi mod start #3206
        //List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and Name = '上京・帰国ナース'];
        List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'DeveloperName20130318'];
		//2014/8/1 daidouzi mod end #3206

		//2014/12/05 daidouzi add start #4248
		//ソリューション登録を取得する
        List<Group> Group_solQue = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'Group_sol'];
		//2014/12/05 daidouzi add end #4248


        System.debug(Logginglevel.WARN, '-------co.size():'+co.size());

		//メディア企画求職者IDキューを取得する
        List<Group> mpIdQue = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'mp_id_que'];

		//所有者が変更されていない求職者を保持する-------------------------------------------------------------
		List<CustomObject1__c> unsetList = new List<CustomObject1__c>();

		//所有者が変更された求職者を保持する-------------------------------------------------------------
		List<CustomObject1__c> settingList = new List<CustomObject1__c>();

        for( CustomObject1__c kyusokusha: co){

			//所有者を変更した場合trueになる
			Boolean ownerSetflag = false;

			//【テスト】を含む場合は処理しない
            if(kyusokusha.Name == null || !kyusokusha.Name.startsWith('【テスト】')){

                System.debug(Logginglevel.WARN, '-------kyusokusha.CC_form_cc_name__c:'+kyusokusha.CC_form_user_id__c);

                //求職者ID取得CC（ユーザーＩＤ)が入力されている場合
                if(kyusokusha.CC_form_user_id__c != null && kyusokusha.CC_form_user_id__c != ''){

                    //所有者に求職者ID取得CC（ユーザーＩＤ)を設定する
                    kyusokusha.OwnerId = kyusokusha.CC_form_user_id__c;
                    ownerSetflag = true; //----------------------------

                    System.debug(Logginglevel.WARN, '-------求職者ID取得CC（ユーザーＩＤ)が入力されている場合:'+kyusokusha.OwnerId);

                }else{

                    //2014/7/30 daidouzi add start #3179
                    //action or action2 にsms_idが設定されている場合は、所有者をキュー（メディア企画求職者ID）に変更
                	if(kyusokusha.action__c != null
                		&& kyusokusha.action__c.indexOf('sms_id_mp') != -1
                	){
                		//メディア企画求職者IDを設定する
	                   	kyusokusha.OwnerId = mpIdQue[0].id;
	                   	ownerSetflag = true; //----------------------------
	                   	System.debug(Logginglevel.WARN, '--action__cにsms_id_mp一致している--');
                	}

                	if(kyusokusha.action2__c != null
                		&& kyusokusha.action2__c.indexOf('sms_id_mp') != -1
                	){
                		//メディア企画求職者IDを設定する
	                   	kyusokusha.OwnerId = mpIdQue[0].id;
	                   	ownerSetflag = true; //----------------------------
	                   	System.debug(Logginglevel.WARN, '--action2__cにsms_id_mp一致している--');

                	}
                    //2014/7/30 daidouzi add end #3179
                }

				//更新前の、求職者を取得する
                CustomObject1__c kyusokushaOld = coOldMap.get(kyusokusha.id);

                //更新前のレコードは使用しない。oldは使わずnewを使う
                //------------------------------------
                kyusokushaOld = kyusokusha;
                //------------------------------------

                System.debug(Logginglevel.WARN, '-------kyusokushaOld:'+kyusokushaOld);

                //更新前の求職者がある場合
                //新規の場合、action__cとaction2__cによって所有者を変更するロジックはWFにて実装している。
                if(kyusokushaOld != null){

					/--* 2014/8/20 daidouzi delete #3274
                	//上京案件がtrueの場合
                	if(kyusokushaOld.Field435__c == true){
                		//キューを設定する
                   		kyusokusha.OwnerId = queueList[0].id;
                   		System.debug(Logginglevel.WARN, '--上京案件がtrue--');
                	}
                	*--/

                	//action__cに"pchp_worldavenue" or "sphp_worldavenue"一致している値が入っている場合
                	if(kyusokushaOld.action__c != null
                		&& (
                			kyusokushaOld.action__c.indexOf('pchp_worldavenue') != -1
                			|| kyusokushaOld.action__c.indexOf('sphp_worldavenue') != -1
                		)
                	){
                		//キューを設定する
                   		kyusokusha.OwnerId = queueList[0].id;
                   		System.debug(Logginglevel.WARN, '--action__cにpchp_worldavenue or sphp_worldavenue一致している--');
                   		ownerSetflag = true; //----------------------------
                	}

                	//action2__cに"pchp_worldavenue" or "sphp_worldavenue"一致している値が入っている場合
                	if(kyusokushaOld.action2__c != null
                		&& (
                			kyusokushaOld.action2__c.indexOf('pchp_worldavenue') != -1
                			|| kyusokushaOld.action2__c.indexOf('sphp_worldavenue') != -1
                		)
                	){
                		//キューを設定する
                   		kyusokusha.OwnerId = queueList[0].id;
                   		System.debug(Logginglevel.WARN, '--action2__cにpchp_worldavenue or sphp_worldavenue一致している--');
                   		ownerSetflag = true; //----------------------------
                	}

					//2014/12/05 daidouzi add start #4248 //
					//キュー設定
                	if(kyusokushaOld.action__c != null
                		&& kyusokushaOld.action__c.indexOf('from_sol') != -1
                	){
                		//「ソリューション登録」キューに割当てる
                   		kyusokusha.OwnerId = Group_solQue[0].id;
                   		System.debug(Logginglevel.WARN, '--action__cにfrom_sol一致している--');
                   		ownerSetflag = true; //----------------------------
                	}
                	//2014/12/05 daidouzi add end #4248

                }


				//----------------------------
				//----------------------------
				//----------------------------
	        	//★保有資格が看護学生と一致の場合はFalse
		        if (kyusokusha.Field14__c == '看護学生') {

		        	System.debug(Logginglevel.WARN, '********* ★保有資格が看護学生と一致');
	        		kyusokusha.DeliveryFlag__c = false;
                    ownerSetflag = true; //----------------------------
	        		//所有者をに変更する。商品設計チーム共通アカウント
	        		kyusokusha.OwnerId = kgOwner.id;

		        }

		        //希望職種：その他自動振り分け（単独選択時）の場合
		        if(kyusokusha.nj_id__c != null
		        	&& kyusokusha.Field16__c == 'その他'
		        	&& (kyusokusha.Field144__c == 'NJB'
		        		|| kyusokusha.Field144__c == 'M_NJB'
		        	)
		        ){
		        	System.debug(Logginglevel.WARN, '********* 希望職種：その他自動振り分け（単独選択時）の場合');
                    ownerSetflag = true; //----------------------------
	        		//所有者をに変更する。山田 宏行アカウント
	        		kyusokusha.OwnerId = otherOwner.id;
		        }

				//ケアリハ:RJB学生自動振り分け
				// 希望職種から登録サイトを決定
            	String site = distributesSite(kyusokusha);
	            if(site == 'PTOTJB'
	            	&& kyusokusha.Field14__c =='学生'
	            ){
	            	//RJB学生専用キュー設定
		        	System.debug(Logginglevel.WARN, '********* ケアリハ:RJB学生自動振り分けの場合');
                    ownerSetflag = true; //----------------------------
	        		//所有者をに変更する。RJB学生専用
	        		kyusokusha.OwnerId = rjbGkusei[0].id;

	            }

				//----------------------------
				//----------------------------
				//----------------------------

	            //所有者を設定しない場合。テスト含むレコードは対象外
	            if(!ownerSetflag){
	            	//未処理Mapに設定
	            	unsetList.add(kyusokusha);

	            //所有者が設定された場合
	            }else{
	            	settingList.add(kyusokusha);
	            }

            }
        }


        //メール送信
		//////////////////////////////////////////////////////////////////////////////start
		//所有者が設定された求職者の所有者にメール送信
		getUserForOwnerId(settingList);
		//////////////////////////////////////////////////////////////////////////////end

        return unsetList;
    }
    */
    /**
     * 求職者ID取得CCから所有者を設定する
     * insert時に通る処理
     *
     * @return 所有者を設定していない求職者リスト
     */
     /*
    public static List<CustomObject1__c> setOwnerForKyusyokuId(CustomObject1__c[] co) {

        System.debug(Logginglevel.WARN, '-------setOwnerForKyusyokuId:'+co.size());

        //看護学生用ユーザ、商品設計チーム共通アカウント取得
        User kgOwner = [select id, Email from User where Username like 'marketingtool-njb@bm-sms.co.jp%' limit 1];

        //希望職種：その他自動振り分け（単独選択時）、山田 宏行アカウント取得
        User otherOwner = [select id, Email from User where Username like 'hiroyuki-yamada@bm-sms.co.jp%' limit 1];

		//所有者が変更されていない求職者を保持する-------------------------------------------------------------
		List<CustomObject1__c> unsetList = new List<CustomObject1__c>();

        for( CustomObject1__c kyusokusha: co){

        	Boolean ownerSetflag = false;

        	//【テスト】を含む場合は処理しない
            if(kyusokusha.Name == null || !kyusokusha.Name.startsWith('【テスト】')){

                System.debug(Logginglevel.WARN, 'kyusokusha.CC_form_cc_name__c:'+kyusokusha.CC_form_user_id__c);

                //求職者ID取得CC（ユーザーＩＤ)が入力されている場合
                if(kyusokusha.CC_form_user_id__c != null && kyusokusha.CC_form_user_id__c != ''){

                	//所有者に求職者ID取得CC（ユーザーＩＤ)を設定する
                    kyusokusha.OwnerId = kyusokusha.CC_form_user_id__c;
                    ownerSetflag = true; //---------------------------------------

                    System.debug(Logginglevel.WARN, 'kyusokusha.OwnerId:'+kyusokusha.OwnerId);
                }

	        	//看護学生の場合
	        	//★保有資格が看護学生と一致の場合はFalse
		        if (kyusokusha.Field14__c == '看護学生') {

		        	System.debug(Logginglevel.WARN, '********* ★保有資格が看護学生と一致');

	        		kyusokusha.DeliveryFlag__c = false;
                    ownerSetflag = true; //----------------------------
	        		//所有者をに変更する。商品設計チーム共通アカウント
	        		kyusokusha.OwnerId = kgOwner.id;

		        }

		        //希望職種：その他自動振り分け（単独選択時）の場合
		        if(kyusokusha.nj_id__c != null
		        	&& kyusokusha.Field16__c == 'その他'
		        	&& (kyusokusha.Field144__c == 'NJB'
		        		|| kyusokusha.Field144__c == 'M_NJB'
		        	)
		        ){
                    ownerSetflag = true; //----------------------------
	        		//所有者をに変更する。山田 宏行アカウント
	        		kyusokusha.OwnerId = otherOwner.id;
		        }


	            //所有者を設定しない場合。テスト含むレコードは対象外
	            if(!ownerSetflag){
	            	//未処理Mapに設定
	            	unsetList.add(kyusokusha);
	            }

            }

        }

        return unsetList;
    }
    */

/*
    public static Map<String, List<String>> getSendTargetAddress(List<CustomObject1__c> kyusyokusyaList, Map<String, CustomObject3__c> trgetTantouAreaMap) {
		System.debug('----担当エリアのその他アドレスに送信---');

    	//メールテンプレート取得 //afterでメール送信するためコメントアウト
		//EmailTemplate templateObj = EmailTemplateDao.getEmailTemplate('EmailTemplate_test');

		//送信対象のメール送信
		List<SendMail__c> sendMailList = new List<SendMail__c>();

		Map<String, List<String>> userListForTantouArea = new Map<String, List<String>>();


		//求職者keyに担当エリアのその他アドレスに送信
    	for(CustomObject1__c kyusyokusya : kyusyokusyaList){

    		//キーはcustomer_id__cを使用する
    		//CustomObject3__c trgetTantouArea = trgetTantouAreaMap.get(kyusyokusya.id);
    		CustomObject3__c trgetTantouArea = trgetTantouAreaMap.get(kyusyokusya.customer_id__c);

    		if(trgetTantouArea != null){

    			//その他メール
    			String otherEmail = trgetTantouArea.OthersSendAddress__c;

    			if(otherEmail != null){
    				//「;」区切りでメールアドレスが入力されている
    				List<String> eMailAddress = otherEmail.split(';');

					List<String> emailadds = new List<String>();

    				for(String email : eMailAddress){

						System.debug('----email---'+ email);

			    		//メール送信作成 //afterでメール送信するためコメントアウト
			    		//SendMail__c sendMail = createSendMailForOwner(templateObj, kyusyokusya, email, null);
			    		//sendMailList.add(sendMail);

			    		//送信先保持
			    		emailadds.add(email);

    				}

    				//keyはユニーク項目 求職者単位で送信先を保持
    				userListForTantouArea.put(kyusyokusya.customer_id__c, emailadds);
    			}
    		}
    	}

    	//afterでメール送信するため、保持する
    	//Utility.setUserListForTantouArea(userListForTantouArea);

		System.debug('----担当エリアのその他アドレスに送信--userListForTantouArea-'+userListForTantouArea);
		System.debug('----担当エリアのその他アドレスに送信---'+sendMailList.size());

    	//afterでメール送信するためコメントアウト
    	if(sendMailList.size() > 0){
    		insert sendMailList;
    	}

		return userListForTantouArea;
    }


*/
}