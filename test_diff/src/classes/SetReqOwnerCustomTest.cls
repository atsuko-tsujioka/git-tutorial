/**
 *
 * 2016/04/26 ogino MATCHING_PROMOTION_SYSTEM-2565
 */
@isTest
private class SetReqOwnerCustomTest {
//add_start_2015/06/02 ogino #4915    
    @testSetup static void setup() {
        createTestDate();
    }
//add_end_2015/06/02 ogino #4915

	//パターン1：担当エリア：住所と求職者：住所が一致または、key(市を除いた区のみ)項目と一致した場合
    static testMethod void myUnitTest01() {

		Map<String, User> userMap = createTestDate();

		User user01 = userMap.get('user01');
		User user02 = userMap.get('user02');
		User user03 = userMap.get('user03');
		User user04 = userMap.get('user04');

		Test.startTest();


		//求職者作成--------------------------
        //常勤の求職者の場合
        //パターン1
        CustomObject1__c jobSeeker01 = new CustomObject1__c(
        	name = 'test1',
        	Field5__c = date.newInstance(2009,8,11),
        	Field16__c = 'ケアマネジャー',
        	Field6__c = '秋葉原県',
        	Field7__c = '横浜市',
        	GGeoCodeNotHandle__c = true,
        	Field17__c = '常勤',
        	Field142__c='3か月以内',
        	entry_category__c = 'CC掘起しTEL'
        	,retirement_intention__c = 'A'
        );

		insert jobSeeker01;
			//insert new List<CustomObject1__c>{jobSeeker01, jobSeeker02, jobSeeker03};

        Test.stopTest();

        CustomObject1__c resultKyusyokusya = getCustomObject1(jobSeeker01.id);
		System.assertEquals(user01.Id, resultKyusyokusya.OwnerId,  'user01=' + user01 + '****resultKyusyokusya.Owner.LastName=' + resultKyusyokusya.Owner.LastName);

    }

	//// パターン2：住所がkeyに前方一致するもので最も短いkeyを検索 （担当エリアkey=神奈川県横浜市, 求職者住所=神奈川県横浜のケース）
    static testMethod void myUnitTest01_02() {

		Map<String, User> userMap = createTestDate();

		User user01 = userMap.get('user01');
		User user02 = userMap.get('user02');
		User user03 = userMap.get('user03');
		User user04 = userMap.get('user04');

		Test.startTest();


		//求職者作成--------------------------
        //常勤の求職者の場合
        // パターン2：住所がkeyに前方一致するもので最も短いkeyを検索 （担当エリアkey=神奈川県横浜市, 求職者住所=神奈川県横浜のケース）
        CustomObject1__c jobSeeker01 = new CustomObject1__c(
        	name = 'test1',
        	Field5__c = date.newInstance(2009,8,11),
        	Field16__c = 'ケアマネジャー',
        	Field6__c = '秋葉原県',
        	Field7__c = '横浜',
        	GGeoCodeNotHandle__c = true,
        	Field17__c = '常勤',
        	Field142__c='3か月以内',
        	entry_category__c = 'CC掘起しTEL'
        	,retirement_intention__c = 'A'
        );

		insert jobSeeker01;
			//insert new List<CustomObject1__c>{jobSeeker01, jobSeeker02, jobSeeker03};

        Test.stopTest();

        CustomObject1__c resultKyusyokusya = getCustomObject1(jobSeeker01.id);
		System.assertEquals(user01.Id, resultKyusyokusya.OwnerId,  'user01=' + user01 + '****resultKyusyokusya.Owner.LastName=' + resultKyusyokusya.Owner.LastName);

    }

	////パターン3： キーが住所に前方一致するもので最も長いkeyを検索 （key=神奈川県横浜市, 住所=神奈川県横浜市西区のケース）
    static testMethod void myUnitTest01_03() {

		Map<String, User> userMap = createTestDate();

		User user01 = userMap.get('user01');
		User user02 = userMap.get('user02');
		User user03 = userMap.get('user03');
		User user04 = userMap.get('user04');

		Test.startTest();


		//求職者作成--------------------------
        //常勤の求職者の場合
        //パターン3： キーが住所に前方一致するもので最も長いkeyを検索 （key=神奈川県横浜市, 住所=神奈川県横浜市西区のケース）
        CustomObject1__c jobSeeker01 = new CustomObject1__c(
        	name = 'test1',
        	Field5__c = date.newInstance(2009,8,11),
        	Field16__c = 'ケアマネジャー',
        	Field6__c = '秋葉原県',
        	Field7__c = '横浜市西区',
        	GGeoCodeNotHandle__c = true,
        	Field17__c = '常勤',
        	Field142__c='3か月以内',
        	entry_category__c = 'CC掘起しTEL'
        	,retirement_intention__c = 'A'
        );

		insert jobSeeker01;

        Test.stopTest();

        CustomObject1__c resultKyusyokusya = getCustomObject1(jobSeeker01.id);
		System.assertEquals(user01.Id, resultKyusyokusya.OwnerId,  'user01=' + user01 + '****resultKyusyokusya.Owner.LastName=' + resultKyusyokusya.Owner.LastName);

    }

 	//パターン4：担当エリア表と一致しない。県名のみ一致。
    static testMethod void myUnitTest01_04() {

		Map<String, User> userMap = createTestDate();

		User user01 = userMap.get('user01');
		User user02 = userMap.get('user02');
		User user03 = userMap.get('user03');
		User user04 = userMap.get('user04');

		Test.startTest();


		//求職者作成--------------------------
        //常勤の求職者の場合
        //パターン4：担当エリア表と一致しない。県名のみ一致。
        CustomObject1__c jobSeeker01 = new CustomObject1__c(
        	name = 'test1',
        	Field5__c = date.newInstance(2009,8,11),
        	Field16__c = 'ケアマネジャー',
        	Field6__c = '秋葉原県',
        	Field7__c = '川崎市',
        	GGeoCodeNotHandle__c = true,
        	Field17__c = '常勤',
        	Field142__c='3か月以内',
        	entry_category__c = 'CC掘起しTEL'
        	,retirement_intention__c = 'A'
        );

		insert jobSeeker01;

        Test.stopTest();

        List<SendMail__c> resultSendMailList = [select id,subject__c,body__c from SendMail__c ];
        for(SendMail__c objSendMail:resultSendMailList){
            System.debug('_/_/_/_/_/objSendMail:');
            System.debug(objSendMail);
        }
		System.assertEquals(resultSendMailList.size(), 1, resultSendMailList.size());

    }

	//非常勤の求職者の場合
    static testMethod void myUnitTest02() {

		//テストデータ作成
		Map<String, User> userMap = createTestDate();

		User user01 = userMap.get('user01');
		User user02 = userMap.get('user02');
		User user03 = userMap.get('user03');
		User user04 = userMap.get('user04');

		Test.startTest();


		//求職者作成--------------------------

        //非常勤の求職者の場合
        CustomObject1__c jobSeeker02 = new CustomObject1__c(
        	name = 'test2',
        	Field5__c = date.newInstance(2009,8,11),
        	Field16__c = 'ケアマネジャー',
        	Field6__c = '秋葉原県',
        	Field7__c = '横浜市',
        	GGeoCodeNotHandle__c = true,
        	Field17__c = '非常勤',
        	Field142__c='3か月以内',
        	entry_category__c = 'CC掘起しTEL'
        	,retirement_intention__c = 'A'

        );

		insert jobSeeker02;

        Test.stopTest();

        CustomObject1__c resultKyusyokusya02 = getCustomObject1(jobSeeker02.id);
		System.assertEquals(user02.Id, resultKyusyokusya02.OwnerId,  'user02=' + user02 + '****resultKyusyokusya.Owner.LastName=' + resultKyusyokusya02.Owner.LastName);

    }

    //割り当て表の登録カテゴリ、踏み絵一致しない場合
    static testMethod void myUnitTest03() {

		//テストデータ作成
		Map<String, User> userMap = createTestDate();

		User user01 = userMap.get('user01');
		User user02 = userMap.get('user02');
		User user03 = userMap.get('user03');
		User user04 = userMap.get('user04');

		Test.startTest();


		//求職者作成--------------------------
        //常勤の求職者の場合
        //割り当て表の登録カテゴリ、踏み絵一致しない場合
        CustomObject1__c jobSeeker01 = new CustomObject1__c(
        	name = 'test1',
        	Field5__c = date.newInstance(2009,8,11),
        	Field16__c = 'ケアマネジャー',
        	Field6__c = '秋葉原県',
        	Field7__c = '横浜市',
        	GGeoCodeNotHandle__c = true,
        	Field17__c = '常勤',
        	Field142__c='3か月以内',
        	entry_category__c = 'DD掘起しTEL'
        	,retirement_intention__c = 'Z'
        );

		insert jobSeeker01;
			//insert new List<CustomObject1__c>{jobSeeker01, jobSeeker02, jobSeeker03};

        Test.stopTest();

        CustomObject1__c resultKyusyokusya01 = getCustomObject1(jobSeeker01.id);
		System.assertEquals(user03.Id, resultKyusyokusya01.OwnerId,  '\nuser=' + user03 + '\n****resultKyusyokusya.Owner.LastName=' + resultKyusyokusya01.Owner.LastName);

    }

	//非常勤の求職者の場合
	//割り当て表の登録カテゴリ、踏み絵一致しない場合
    static testMethod void myUnitTest04() {

		//テストデータ作成
		Map<String, User> userMap = createTestDate();

		User user01 = userMap.get('user01');
		User user02 = userMap.get('user02');
		User user03 = userMap.get('user03');
		User user04 = userMap.get('user04');

		Test.startTest();

		//求職者作成--------------------------
        //非常勤の求職者の場合
        //割り当て表の登録カテゴリ、踏み絵一致しない場合
        CustomObject1__c jobSeeker01 = new CustomObject1__c(
        	name = 'test1',
        	Field5__c = date.newInstance(2009,8,11),
        	Field16__c = 'ケアマネジャー',
        	Field6__c = '秋葉原県',
        	Field7__c = '横浜市',
        	GGeoCodeNotHandle__c = true,
        	Field17__c = '非常勤',
        	Field142__c='3か月以内',
        	entry_category__c = 'DD掘起しTEL'
        	,retirement_intention__c = 'Z'
        );

		insert jobSeeker01;

        Test.stopTest();

        CustomObject1__c resultKyusyokusya01 = getCustomObject1(jobSeeker01.id);
		System.assertEquals(user04.Id, resultKyusyokusya01.OwnerId,  '\nuser=' + user04 + '\n****resultKyusyokusya.Owner.LastName=' + resultKyusyokusya01.Owner.LastName);

    }


	//登録サイトチェック
    static testMethod void myUnitTestDistributesSite01() {

    	//--------------------------------
        CustomObject1__c kyusyokusya = new CustomObject1__c(
        	Field14__c=''
        	,Field16__c='看護師（正看・准看）'
        );

    	String result = SetReqOwnerCustom.distributesSite(kyusyokusya);
		System.assert(result == 'NJB', result);

        kyusyokusya = new CustomObject1__c(
        	Field14__c='看護師'
        	,Field16__c='その他'
        );

    	result = SetReqOwnerCustom.distributesSite(kyusyokusya);
		System.assert(result == 'NJB', result);

    }

	//登録サイトチェック
    static testMethod void myUnitTestDistributesSite02() {

    	//--------------------------------
        CustomObject1__c kyusyokusya = new CustomObject1__c(
        	Field14__c=''
        	,Field16__c='理学療法士（PT）'
        );

    	String result = SetReqOwnerCustom.distributesSite(kyusyokusya);
		System.assert(result == 'PTOTJB', result);

        kyusyokusya = new CustomObject1__c(
        	Field14__c='理学療法士（PT）'
        	,Field16__c='その他'
        );

    	result = SetReqOwnerCustom.distributesSite(kyusyokusya);
		System.assert(result == 'PTOTJB', result);
    }

	//登録サイトチェック
    static testMethod void myUnitTestDistributesSite03() {

    	//--------------------------------
        CustomObject1__c kyusyokusya = new CustomObject1__c(
        	Field14__c=''
        	,Field16__c='ケアマネジャー'
        );

    	String result = SetReqOwnerCustom.distributesSite(kyusyokusya);
		System.assert(result == 'CJB', result);

        kyusyokusya = new CustomObject1__c(
        	Field14__c='ケアマネジャー'
        	,Field16__c='その他'
        );

    	result = SetReqOwnerCustom.distributesSite(kyusyokusya);
		System.assert(result == 'CJB', result);
    }

	//登録サイトチェック
    static testMethod void myUnitTestDistributesSite04() {

    	//--------------------------------
        CustomObject1__c kyusyokusya = new CustomObject1__c(
        	Field14__c='基本情報試験'
        );
    	String result = SetReqOwnerCustom.distributesSite(kyusyokusya);
		System.assert(result == 'その他', result);
    }



    // ---------------------------------------------
    // setOwner() のテストメソッド　所有者がキューに変更になる
    // ---------------------------------------------
    public static testMethod void testSetOwner0020() {

		// カスタム設定登録
		createTestDateOrganizationSetting();


        // ログイン中のユーザの Id を取得する
        String uid = UserInfo.getUserId();

		/*
		Group gObj = new Group(
			name = '上京・帰国ナース'
			,Type='Queue'
		);

		insert gObj;
		*/

		//キューを取得する
		//del_start_2016/02/22 ogino #9695
        ////2014/8/1 daidouzi mod start #3206
        ////List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and Name = '上京・帰国ナース'];
        //List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'DeveloperName20130318'];
		////2014/8/1 daidouzi mod end #3206
        //del_end_2016/02/22 ogino #9695
        //add_start_2016/02/22 ogino #9695
        List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'notSendEmailGroup'];
        //add_end_2016/02/22 ogino #9695

        //重複を作成する
        CustomObject1__c c1_1 = new CustomObject1__c(
        	name='test1'
        	,Field5__c=date.today()
        	,customer_id__c='1234567'
        	,Field2__c='1117'
        	,Field16__c='ケアマネジャー'
        	,Field6__c='秋葉原県',Field7__c='横浜市'
        	,GGeoCodeNotHandle__c=true,Field17__c='常勤'
        	, Field142__c='3か月以内'
	        //,Field435__c = true //2015/3/2 daidouzi add #4634 //2015 daidouzi delete #4938
	        ,Action__c = 'sphp_worldavenue'  ////2015/3/2 daidouzi add #4634

        );

        insert c1_1;

        CustomObject1__c c1_1_result = [select id,name,ownerId from CustomObject1__c where id=:c1_1.id];
        //c1_1_result.Field435__c = true; //2015 daidouzi delete #4938
        c1_1_result.Action__c = 'sphp_worldavenue';

		List<CustomObject1__c> clist = new List<CustomObject1__c>();
		clist.add(c1_1);

		Map<id, CustomObject1__c> cmap = new Map<id, CustomObject1__c> ();
		//第一引数：更新後の値、第二引数：更新前
		cmap.put(c1_1_result.id, c1_1_result);

		//所有者変更
    	//setReqOwner.setOwner(clist, cmap) ;
    	SetReqOwnerCustom.setOwner(clist, cmap) ;

        // 所有者が正しく設定されていることを確認する
        //所有者がキューになっていることを確認
        //System.assertEquals(clist[0].Ownerid, queueList[0].id,clist[0].Ownerid);
    }
    // ---------------------------------------------
    // setOwner() のテストメソッド　所有者がキューに変更になる.RJB学生用
    // ---------------------------------------------
    public static testMethod void testSetOwner030() {

		// カスタム設定登録
		createTestDateOrganizationSetting();

		//キューを取得する
		//2014/8/1 daidouzi mod start #3206
		//
        List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'RJB_student'];
		//2014/8/1 daidouzi mod end #3206

        //重複を作成する
        CustomObject1__c c1_1 = new CustomObject1__c(
        	name='test1'
        	,Field5__c=date.today()
        	,customer_id__c='1234567'
        	,Field2__c='1117'
        	,Field6__c='秋葉原県',Field7__c='横浜市'
        	,GGeoCodeNotHandle__c=true,Field17__c='常勤'
        	, Field142__c='3か月以内'
        	,Field16__c='その他'
        	,Field14__c='学生'

        );

        insert c1_1;

		List<CustomObject1__c> clist = new List<CustomObject1__c>();
		clist.add(c1_1);

		//所有者変更
    	SetReqOwnerCustom.setOwner(clist) ;

        // 所有者が正しく設定されていることを確認する
        //所有者がキューになっていることを確認
        System.assertEquals(clist[0].Ownerid, queueList[0].id,clist[0].Ownerid);
    }
    // ---------------------------------------------
    // setOwner() のテストメソッド　所有者がキューに変更になる.Sol経由の登録者をSOLユーザに割振る
    // ---------------------------------------------
    public static testMethod void testSetOwner040() {

		// カスタム設定登録
		createTestDateOrganizationSetting();

        //del_start_2016/02/22 ogino #9695
        //List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'Group_sol'];
        //del_end_2016/02/22 ogino #9695
        //add_start_2016/02/22 ogino #9695
        List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'notSendEmailGroup'];
        //add_end_2016/02/22 ogino #9695
        //作成する
        CustomObject1__c c1_1 = new CustomObject1__c(
        	name='test1'
        	,Field5__c=date.today()
        	,customer_id__c='1234567'
        	,Field2__c='1117'
        	,Field6__c='秋葉原県',Field7__c='横浜市'
        	,GGeoCodeNotHandle__c=true,Field17__c='常勤'
        	, Field142__c='3か月以内'
        	,action__c='from_sol'

        );

        insert c1_1;

		List<CustomObject1__c> clist = new List<CustomObject1__c>();
		clist.add(c1_1);

		//所有者変更
    	SetReqOwnerCustom.setOwner(clist) ;

        // 所有者が正しく設定されていることを確認する
        //所有者がキューになっていることを確認
        //System.assertEquals(clist[0].Ownerid, queueList[0].id,clist[0].Ownerid);
    }
    // ---------------------------------------------
    // setOwner() のテストメソッド　所有者がキューに変更になる.看護学生自動振り分け W
    // ---------------------------------------------
    public static testMethod void testSetOwner050() {

		// カスタム設定登録
		createTestDateOrganizationSetting();

        List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'ProductDesignTeam'];

        //作成する
        CustomObject1__c c1_1 = new CustomObject1__c(
        	name='test1'
        	,Field5__c=date.today()
        	,customer_id__c='1234567'
        	,Field2__c='1117'
        	,Field6__c='秋葉原県',Field7__c='横浜市'
        	,GGeoCodeNotHandle__c=true,Field17__c='常勤'
        	, Field142__c='3か月以内'
        	,Field14__c='看護学生'

        );

        insert c1_1;

		List<CustomObject1__c> clist = new List<CustomObject1__c>();
		clist.add(c1_1);

		//所有者変更
    	SetReqOwnerCustom.setOwner(clist) ;

        // 所有者が正しく設定されていることを確認する
        //所有者がキューになっていることを確認
        System.assertEquals(clist[0].Ownerid, queueList[0].id,clist[0].Ownerid);
    }
    // ---------------------------------------------
    // setOwner() のテストメソッド　所有者がキューに変更になる.希望職種：その他自動振り分け
    // ---------------------------------------------
    public static testMethod void testSetOwner060() {

		// カスタム設定登録
		createTestDateOrganizationSetting();

        List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'HopeJobCategoryOtherGroup'];

        //作成する
        CustomObject1__c c1_1 = new CustomObject1__c(
        	name='test1'
        	,Field5__c=date.today()
        	,customer_id__c='1234567'
        	,Field2__c='1117'
        	,Field6__c='秋葉原県'
        	,Field7__c='横浜市'
        	,GGeoCodeNotHandle__c=true
        	,Field17__c='常勤'
        	,Field142__c='3か月以内'
        	,Field16__c='その他'
        	,Field144__c='NJB'
        	,nj_id__c ='1234567'

        );

        insert c1_1;

		List<CustomObject1__c> clist = new List<CustomObject1__c>();
		clist.add(c1_1);

		//所有者変更
    	SetReqOwnerCustom.setOwner(clist) ;

        // 所有者が正しく設定されていることを確認する
        //所有者がキューになっていることを確認
        System.assertEquals(clist[0].Ownerid, queueList[0].id,clist[0].Ownerid);
    }

    //　FunctionalUnitSentAddress__c使用箇所対応(myUnitTest01がベース) 2015/08/03 yoshinaga add
    static testMethod void myUnitTest900() {

        Map<String, User> userMap = createTestDate();

        User user01 = userMap.get('user01');
        User user02 = userMap.get('user02');
        User user03 = userMap.get('user03');
        User user04 = userMap.get('user04');

        Test.startTest();


        //求職者作成--------------------------
        //常勤の求職者の場合
        //パターン1
        CustomObject1__c jobSeeker01 = new CustomObject1__c(
            name = 'test1',
            Field5__c = date.newInstance(2009,8,11),
            Field16__c = 'ケアマネジャー',
            Field6__c = '秋葉原県',
            Field7__c = '横浜市',
            GGeoCodeNotHandle__c = true,
            Field17__c = '常勤',
            Field142__c='3か月以内',
            entry_category__c = 'CC掘起しTEL'
            ,retirement_intention__c = 'A'
        );

        insert jobSeeker01;
            //insert new List<CustomObject1__c>{jobSeeker01, jobSeeker02, jobSeeker03};

        Test.stopTest();

        CustomObject1__c resultKyusyokusya = getCustomObject1(jobSeeker01.id);
        System.assertEquals(user01.Id, resultKyusyokusya.OwnerId,  'user01=' + user01 + '****resultKyusyokusya.Owner.LastName=' + resultKyusyokusya.Owner.LastName);

    }

    //　distributesSite対応 2015/08/03 yoshinaga add
    static testMethod void myUnitTest4distributesSite() {

        CustomObject1__c jobSeeker01 = new CustomObject1__c(
            name = 'test1',
            Field5__c = date.newInstance(2009,8,11),
            Field16__c = 'テスト職種',
            Field6__c = '秋葉原県',
            Field7__c = '横浜市',
            GGeoCodeNotHandle__c = true,
            Field17__c = '常勤',
            Field142__c='3か月以内',
            entry_category__c = 'CC掘起しTEL'
            ,retirement_intention__c = 'A'
        );

        insert jobSeeker01;

        Test.startTest();
        SetReqOwnerCustom.distributesSite(jobSeeker01);
        Test.stopTest();
    }

    //　setOwnerRunForPage対応 2015/08/03 yoshinaga add
    static testMethod void myUnitTest4setOwnerRunForPage() {

        CustomObject1__c jobSeeker01 = new CustomObject1__c(
            name = 'test1',
            Field5__c = date.newInstance(2009,8,11),
            Field16__c = 'テスト職種',
            Field6__c = '秋葉原県',
            Field7__c = '横浜市',
            GGeoCodeNotHandle__c = true,
            Field17__c = '常勤',
            Field142__c='3か月以内',
            entry_category__c = 'CC掘起しTEL'
            ,retirement_intention__c = 'A'
        );
        
        insert jobSeeker01;
        
        List <CustomObject1__c> customObject1List = new List <CustomObject1__c> ();
        customObject1List.add (jobSeeker01);
        

        Test.startTest();
        SetReqOwnerCustom.setOwnerRunForPage(customObject1List, '常勤');
        Test.stopTest();
    }

	private static CustomObject1__c getCustomObject1(String kid){

		return [
			select
				OwnerId
				,Owner.Name
				,Owner.LastName
				,Owner.FirstName
				,Name
			from
				CustomObject1__c
			WHERE
				Id =:kid
			];
	}

    private static void createTestDateOrganizationSetting(){
        //add_start_2015/06/02 ogino #4915
        if(OrganizationSettings__c.getInstance() != null){
            return;
        }
        //add_end_2015/06/02 ogino #4915
		// カスタム設定登録
		OrganizationSettings__c os = new OrganizationSettings__c(
			JobSeekerSynchronizationDate__c = -3
			,CandidateCulcInsertFlag__c = true
			//,NewAllocationLogic__c = true
			//,NewAllocationLogicCustom__c = true
		);

		insert os;
    }


    private static Map<String, User> createTestDate(){

		// カスタム設定登録
		createTestDateOrganizationSetting();
		
		//add_start_2015/06/02 ogino #4915
		List<User> userList = 
		  [SELECT 
		      Id
		      ,Name
		      ,LastName
		      ,FirstName
		      ,Alias
		      ,Email
		      ,Username
		      ,CommunityNickname
		      ,EmailEncodingKey
		      ,TimeZoneSidKey
		      ,LanguageLocaleKey
		      ,LocaleSidKey
		      ,ProfileId
		  FROM
		      User
		  WHERE
		      Email IN ('user1wari@test.com','user2wari@test.com','user3wari@test.com','user4wari@test.com')
		  ];
		  
		if(!userList.isEmpty()){
		  Map<String,User> userMap = new Map<String,User>();
		  for(User objUser:userList){
		      if(objUser.Email == 'user1wari@test.com'){
		          userMap.put('user01',objUser);
		      }else if(objUser.Email == 'user2wari@test.com'){
                  userMap.put('user02',objUser);
              }else if(objUser.Email == 'user3wari@test.com'){
                  userMap.put('user03',objUser);
              }else if(objUser.Email == 'user4wari@test.com'){
                  userMap.put('user04',objUser);
              }
		  }
		  return userMap;
		}
		//add_end_2015/06/02 ogino #4915

		//割り振り担当者を生成する--------------------------

		String profileId = [SELECT Id FROM Profile WHERE Name = 'システム管理者'].Id;

        //割り振り担当者01
    	User user01 = new User();
    	user01.LastName = '割り振り担当者/担当キューID';
    	user01.FirstName = '担当者01';
    	user01.Alias = 'テストメソッド';
    	user01.Email = 'user1wari@test.com';
    	user01.Username = 'username1wari@test.com';
    	user01.CommunityNickname = 'nickname1@test.com';
    	user01.EmailEncodingKey = 'ISO-2022-JP';
    	user01.TimeZoneSidKey = 'Asia/Tokyo';
    	user01.LanguageLocaleKey = 'ja';
    	user01.LocaleSidKey = 'ja_JP';
		user01.ProfileId = profileId;
    	insert user01;

        //割り振り担当者02
    	User user02 = new User();
    	user02.LastName = '割り振り(非常勤)担当者/担当キューID';
    	user02.FirstName = '担当者02';
    	user02.Alias = 'テストメソッド';
    	user02.Email = 'user2wari@test.com';
    	user02.Username = 'username2wari@test.com';
    	user02.CommunityNickname = 'nickname2@test.com';
    	user02.EmailEncodingKey = 'ISO-2022-JP';
    	user02.TimeZoneSidKey = 'Asia/Tokyo';
    	user02.LanguageLocaleKey = 'ja';
    	user02.LocaleSidKey = 'ja_JP';
		user02.ProfileId = profileId;
    	insert user02;

        //割り振り担当者03
    	User user03 = new User();
    	user03.LastName = '割り振りメディア企画担当者キューID';
    	user03.FirstName = '担当者01';
    	user03.Alias = 'テストメソッド';
    	user03.Email = 'user3wari@test.com';
    	user03.Username = 'username3wari@test.com';
    	user03.CommunityNickname = 'nickname3@test.com';
    	user03.EmailEncodingKey = 'ISO-2022-JP';
    	user03.TimeZoneSidKey = 'Asia/Tokyo';
    	user03.LanguageLocaleKey = 'ja';
    	user03.LocaleSidKey = 'ja_JP';
		user03.ProfileId = profileId;
    	insert user03;

        //割り振り担当者04
    	User user04 = new User();
    	user04.LastName = '割り振り(非常勤)メディア企画担当者キューID';
    	user04.FirstName = '担当者02';
    	user04.Alias = 'テストメソッド';
    	user04.Email = 'user4wari@test.com';
    	user04.Username = 'username4wari@test.com';
    	user04.CommunityNickname = 'nickname4@test.com';
    	user04.EmailEncodingKey = 'ISO-2022-JP';
    	user04.TimeZoneSidKey = 'Asia/Tokyo';
    	user04.LanguageLocaleKey = 'ja';
    	user04.LocaleSidKey = 'ja_JP';
		user04.ProfileId = profileId;
    	insert user04;

		//担当エリア作成---------------------------------------

        //登録カテゴリ無し担当エリア表
        CustomObject3__c tantoArea01 = new CustomObject3__c(
        	Name = '1',
        	Field1__c = '秋葉原県',
        	Field2__c = '横浜市',

        	site__c = 'CJB',

        	OwnerId__c = user01.Id, 			//担当者/担当キューID
        	PartTimeOwnerId__c = user02.Id,		//(非常勤)担当者/担当キューID
        	FC_OwnerId__c = user03.Id,			//メディア企画担当者キューID
        	PartTime_FC_OwnerId__c = user04.Id	//(非常勤)メディア企画担当者キューID

        	,Distribution_pattern_fulltime__c = '1(常勤メイン)' 	//【システム用】振り分けパターン(常勤)
        	,Distribution_pattern_shorttime__c = '3(非常勤)'		//【システム用】振り分けパターン(非常勤)
        );
        insert tantoArea01;

        //登録カテゴリ有り担当エリア表
        CustomObject3__c tantoArea02 = new CustomObject3__c(
        	Name = '2',
        	Field1__c = '秋葉原県',
        	Field2__c = '横浜市',

        	site__c = 'CJB',

        	OwnerId__c = user01.Id, 			//担当者/担当キューID
        	PartTimeOwnerId__c = user02.Id,		//(非常勤)担当者/担当キューID
        	FC_OwnerId__c = user03.Id,			//メディア企画担当者キューID
        	PartTime_FC_OwnerId__c = user04.Id	//(非常勤)メディア企画担当者キューID

        	,Distribution_pattern_fulltime__c = '1(常勤メイン)' 	//【システム用】振り分けパターン(常勤)
        	,Distribution_pattern_shorttime__c = '3(非常勤)'		//【システム用】振り分けパターン(非常勤)
        );
        insert tantoArea02;


		//割り当て表作成---------------------------------------

		OwnerDistribution__c ownerDistribution01 = new OwnerDistribution__c(
			//【システム用】振り分けパターン
			Distribution_pattern__c = '1(常勤メイン)'
			//転職希望時期
			,Req_date__c = '3か月以内'
			//登録カテゴリ
			,entry_category__c = '掘起しPCメルマガ;掘起しMBメルマガ;掘起しDM;MP掘起しTEL;CC掘起しTEL'
			//踏み絵選択肢
			,Allegiance_test__c = 'A; B; D;'
		);

		insert ownerDistribution01;

		OwnerDistribution__c ownerDistribution02 = new OwnerDistribution__c(
			//【システム用】振り分けパターン
			Distribution_pattern__c = '3(非常勤)'
			//転職希望時期
			,Req_date__c = '3か月以内'
			//登録カテゴリ
			,entry_category__c = '掘起しPCメルマガ;掘起しMBメルマガ;掘起しDM;MP掘起しTEL;CC掘起しTEL'
			//踏み絵選択肢
			,Allegiance_test__c = 'A; B; D;'
		);

		insert ownerDistribution02;


		//戻り値作成
		Map<String, User> userMap = new Map<String, User>();

		userMap.put('user01', user01);
		userMap.put('user02', user02);
		userMap.put('user03', user03);
		userMap.put('user04', user04);

		return userMap;


    }

	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	//このラインから下の部分はSetReqOwnerCustomTest02から移植
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------


    public static testMethod void testSetOwner04() {
		// カスタム設定登録
		createTestDateOrganizationSetting00();
        System.debug( 'testSetOwner03 start');
        // 経路のテストを行う


        // ログイン中のユーザの Id を取得する
        String uid = UserInfo.getUserId();

        // 担当者を適当に 12人選択する
        List<User> usr = [select Id from User where isActive=TRUE limit 19];
        system.assertEquals(19, usr.size());    // 19人見つかったことを確認
        for (User u: usr) {
            System.debug(Logginglevel.WARN, '****** user id=' + u.Id);
        }


test.startTest();

test.stopTest();
    }

    public static testMethod void testSetOwner04_5() {
		// カスタム設定登録
		createTestDateOrganizationSetting00();

        System.debug( 'testSetOwner03 start');
        // 経路のテストを行う


        // ログイン中のユーザの Id を取得する
        String uid = UserInfo.getUserId();

        // 担当者を適当に 12人選択する
        List<User> usr = [select Id from User where isActive=TRUE limit 19];
        system.assertEquals(19, usr.size());    // 19人見つかったことを確認
        for (User u: usr) {
            System.debug(Logginglevel.WARN, '****** user id=' + u.Id);
        }
    }



    public static testMethod void testSetOwner03() {
		// カスタム設定登録
		createTestDateOrganizationSetting00();

        System.debug( 'testSetOwner03 start');
        // 経路のテストを行う


        // ログイン中のユーザの Id を取得する
        String uid = UserInfo.getUserId();

        // 担当者を適当に 12人選択する
        List<User> usr = [select Id from User where isActive=TRUE limit 19];
        system.assertEquals(19, usr.size());    // 19人見つかったことを確認
        for (User u: usr) {
            System.debug(Logginglevel.WARN, '****** user id=' + u.Id);
        }

        CustomObject1__c c1;

        // 求職者を作成する （希望雇用形態による） Kyushokusha.OwnerId = Tantou.OwnerId__c;
        c1 = new CustomObject1__c(action__c='abc', job_id_type__c='一括応募', name='test1',Field5__c=date.newInstance(2009,8,11),Field2__c='1116',Field16__c='ケアマネジャー',Field6__c='秋葉原県',Field7__c='横浜市',GGeoCodeNotHandle__c=true,Field17__c='常勤', Field142__c='3か月以内');
        insert c1;
        c1 = [SELECT Id, Name, ownerId, entry_course_category__c, entry_course_detail__c, tmp_value_1__c, tmp_value_2__c, tmp_value_3__c, tmp_value_4__c, tmp_value_5__c FROM CustomObject1__c WHERE Id = :c1.Id];

        c1 = new CustomObject1__c(action__c='abc', job_id_type__c='それ以外', name='test1',Field5__c=date.newInstance(2009,8,11),Field2__c='1117',Field16__c='ケアマネジャー',Field6__c='秋葉原県',Field7__c='横浜市',GGeoCodeNotHandle__c=true,Field17__c='常勤', Field142__c='4か月以内');
        insert c1;
        c1 = [SELECT Id, Name, ownerId, entry_course_category__c, entry_course_detail__c, tmp_value_1__c, tmp_value_2__c, tmp_value_3__c, tmp_value_4__c, tmp_value_5__c FROM CustomObject1__c WHERE Id = :c1.Id];

        c1 = new CustomObject1__c(action__c='bbbb', job_id_type__c='一括応募', name='test1',Field5__c=date.newInstance(2009,8,11),Field2__c='1118',Field16__c='ケアマネジャー',Field6__c='秋葉原県',Field7__c='横浜市',GGeoCodeNotHandle__c=true,Field17__c='非常勤', Field142__c='3か月以内');
        insert c1;
        c1 = [SELECT Id, Name, ownerId, entry_course_category__c, entry_course_detail__c, tmp_value_1__c, tmp_value_2__c, tmp_value_3__c, tmp_value_4__c, tmp_value_5__c FROM CustomObject1__c WHERE Id = :c1.Id];

        c1 = new CustomObject1__c(action__c='eee', job_id_type__c='会社登録', name='test1',Field5__c=date.newInstance(2009,8,11),Field2__c='1119',Field16__c='ケアマネジャー',Field6__c='秋葉原県',Field7__c='横浜市',GGeoCodeNotHandle__c=true,Field17__c='非常勤', Field142__c='11か月');
        insert c1;
        c1 = [SELECT Id, Name, ownerId, entry_course_category__c, entry_course_detail__c, tmp_value_1__c, tmp_value_2__c, tmp_value_3__c, tmp_value_4__c, tmp_value_5__c FROM CustomObject1__c WHERE Id = :c1.Id];

    }


    public static testMethod void testSetOwner02() {

		// カスタム設定登録
		createTestDateOrganizationSetting00();


        // ログイン中のユーザの Id を取得する
        String uid = UserInfo.getUserId();

        // 担当者を適当に 12人選択する
        List<User> usr = [select Id from User where isActive=TRUE limit 19];
        system.assertEquals(19, usr.size());    // 19人見つかったことを確認
        for (User u: usr) {
            System.debug(Logginglevel.WARN, '****** user id=' + u.Id);
        }

test.startTest();

test.stopTest();
    }


    public static testMethod void testSetOwner02_2() {

		// カスタム設定登録
		createTestDateOrganizationSetting00();

        // ログイン中のユーザの Id を取得する
        String uid = UserInfo.getUserId();

        // 担当者を適当に 3人選択する
        List<User> usr = [select Id from User where isActive=TRUE limit 3];
        system.assertEquals(3, usr.size());    // 5人見つかったことを確認
        for (User u: usr) {
            System.debug(Logginglevel.WARN, '****** user id=' + u.Id);
        }

        // 担当者キューを3人分作る
        List<Group> groups = new List<Group>();
        groups.add( new Group( Name='aiuoe'));
        groups.add( new Group( Name='kakikukeko'));
        groups.add( new Group( Name='sashisuseso'));
        insert groups;
    }

    // ---------------------------------------------
    // setOwner() のテストメソッド
    // ---------------------------------------------
    public static testMethod void testSetOwner() {
		// カスタム設定登録
		createTestDateOrganizationSetting00();

        // ログイン中のユーザの Id を取得する
        String uid = UserInfo.getUserId();

        // 担当者を適当に 12人選択する
        List<User> usr = [select Id from User where isActive=TRUE limit 19];
        system.assertEquals(19, usr.size());    // 12人見つかったことを確認
        for (User u: usr) {
            System.debug(Logginglevel.WARN, 'user id=' + u.Id);
        }

        CustomObject1__c cx2 = new CustomObject1__c(name='【テスト】test',Field5__c=date.newInstance(2009,8,11),Field2__c='9333',Field151__c=true,Field16__c='作業療法士',Field6__c='秋葉原県',Field21__c='横浜市南区',GGeoCodeNotHandle__c=true,Field17__c='非常勤', Field142__c='3か月以内');             // テスト用データ
        CustomObject1__c cx3 = new CustomObject1__c(name='test1',Field5__c=date.newInstance(2009,8,11),Field2__c='1112',Field151__c=true,Field16__c='ケアマネジャー',Field6__c='秋葉原県',Field7__c='横浜市',GGeoCodeNotHandle__c=true, Field142__c='3か月以内');                                           // ★希望雇用形態がない
        List<CustomObject1__c> cx = new CustomObject1__c[]{ cx2, cx3};

        insert cx;

        // 所有者が変わらないことを確認する
        cx = [select OwnerId from CustomObject1__c where Id in :cx];
        for (CustomObject1__c c: cx) {
            system.assertEquals(uid, c.OwnerId,c);
        }

        // 求職者を作成する （担当者を割り当てるパターン）
        CustomObject1__c c1 = new CustomObject1__c(name='test1',Field5__c=date.newInstance(2009,8,11),Field2__c='1116',Field16__c='ケアマネジャー',Field6__c='秋葉原県',Field7__c='横浜市',GGeoCodeNotHandle__c=true,Field17__c='常勤', Field142__c='3か月以内');
        CustomObject1__c c2 = new CustomObject1__c(name='test2',Field5__c=date.newInstance(2009,8,11),Field2__c='2222',Field16__c='薬剤師',Field6__c='秋葉原県',Field21__c='横浜',GGeoCodeNotHandle__c=true,Field17__c='非常勤', Field142__c='3か月以内');
        CustomObject1__c c3 = new CustomObject1__c(name='test3',Field5__c=date.newInstance(2009,8,11),Field2__c='3333',Field16__c='看護師',Field6__c='秋葉原県',Field21__c='横浜市西区',GGeoCodeNotHandle__c=true,Field17__c='非常勤', Field142__c='3か月以内');
        CustomObject1__c c4 = new CustomObject1__c(name='test4',Field5__c=date.newInstance(2009,8,11),Field2__c='4444',Field16__c='施設ケアマネジャー',Field6__c='秋葉原県',GGeoCodeNotHandle__c=true,Field17__c='常勤', Field142__c='3か月以内');
        CustomObject1__c c5 = new CustomObject1__c(name='test5',Field5__c=date.newInstance(2009,8,11),Field2__c='5555',Field16__c='その他',Field6__c='aaaa',GGeoCodeNotHandle__c=true,Field17__c='非常勤', Field142__c='3か月以内');
        CustomObject1__c c6 = new CustomObject1__c(name='test6',Field5__c=date.newInstance(2009,8,11),Field2__c='6666',Field16__c='施設ケアマネジャー',GGeoCodeNotHandle__c=true,Field17__c='常勤', Field142__c='3か月以内');
        CustomObject1__c c7 = new CustomObject1__c(name='test7',Field5__c=date.newInstance(2009,8,11),Field2__c='7333',Field16__c='医師',Field6__c='秋葉原県',Field21__c='横浜',GGeoCodeNotHandle__c=true,Field17__c='非常勤', Field142__c='3か月以内');
        CustomObject1__c c8 = new CustomObject1__c(name='test8',Field5__c=date.newInstance(2009,8,11),Field2__c='8333',Field16__c='理学療法士',Field6__c='秋葉原県',Field21__c='横浜市西区',GGeoCodeNotHandle__c=true,Field17__c='常勤', Field142__c='3か月以内');
        CustomObject1__c c9 = new CustomObject1__c(name='test9',Field5__c=date.newInstance(2009,8,11),Field2__c='9334',Field16__c='作業療法士',Field6__c='秋葉原県',Field21__c='横浜市南区',GGeoCodeNotHandle__c=true,Field17__c='非常勤', Field142__c='3か月以内');
        CustomObject1__c cA = new CustomObject1__c(name='testA',Field5__c=date.newInstance(2009,8,11),Field2__c='9335',Field16__c='言語聴覚士',Field6__c='秋葉原県',GGeoCodeNotHandle__c=true,Field17__c='常勤', Field142__c='3か月以内');
        CustomObject1__c cB = new CustomObject1__c(name='testB',Field5__c=date.newInstance(2009,8,11),Field2__c='9336',Field16__c=null,Field6__c='秋葉原県',Field21__c='横浜市',Field17__c='非常勤', Field142__c='3か月以内');
        CustomObject1__c cC = new CustomObject1__c(name='testC',Field5__c=date.newInstance(2009,8,11),Field2__c='9337',Field16__c='看護師',Field6__c='秋葉原県',Field21__c='横浜市南区',Field17__c='非常勤', Field142__c='3か月以内');
        List<CustomObject1__c> cn = new CustomObject1__c[]{c1, c2, c3, c4, c5, c6, c7, c8, c9, cA, cB, cC};
        insert cn;
        for (CustomObject1__c c: cn) {
            System.debug(Logginglevel.WARN, '求職者Id=' + c.Id);
        }

        // 所有者が正しく設定されていることを確認する
        // 1. 正解表を作成する
        Map<Id, Id> expect = new Map<Id,Id>();  // 求職者Id と所有者Id のマップ （正解表）
        expect.put(c1.Id, usr[8].Id);   // match2 のパターン / 希望職種=ケアマネジャー / 常勤
        expect.put(c2.Id, usr[3].Id);   // match2 のパターン / 希望職種=薬剤師 / 非常勤
        expect.put(c3.Id, uid);         // 住所も希望職種もマッチしないパターン / 希望職種=看護師
        expect.put(c4.Id, usr[10].Id);  // match4 のパターン / 希望職種=施設ケアマネジャー
        expect.put(c5.Id, usr[11].Id);  // match4 のパターン / 希望職種=その他
        expect.put(c6.Id, usr[10].Id);  // match4 のパターン  / 住所なし
        expect.put(c7.Id, usr[1].Id);   // match3 のパターン
        expect.put(c8.Id, uid);         // 理学療法士 → PTOTJB をカバーするため
        expect.put(c9.Id, uid);         // 作業療法士 → PTOTJB をカバーするため
        expect.put(cA.Id, uid);         // 言語聴覚士 → PTOTJB をカバーするため
        expect.put(cB.Id, usr[11].Id);  // match2 のパターン  / 希望職種なし
        expect.put(cC.Id, usr[5].Id);   // match1 のパターン

    }

    // ---------------------------------------------
    // setOwner() のテストメソッド　所有者がキューに変更になる
    // ---------------------------------------------
    public static testMethod void testSetOwner020() {

		// カスタム設定登録
		createTestDateOrganizationSetting00();

        // ログイン中のユーザの Id を取得する
        String uid = UserInfo.getUserId();
		//キューを取得する
        List<Group> queueList = [SELECT Id, Name FROM Group WHERE Type='Queue' and DeveloperName = 'notSendEmailGroup'];
        //add_end_2016/02/22 ogino #9695

        //重複を作成する
        CustomObject1__c c1_1 = new CustomObject1__c(name='test1',Field5__c=date.today(),customer_id__c='1234567',Field2__c='1117',Field16__c='ケアマネジャー',Field6__c='秋葉原県',Field7__c='横浜市',GGeoCodeNotHandle__c=true,Field17__c='常勤', Field142__c='3か月以内'
	        ,Action__c = 'sphp_worldavenue'  ////2015/3/2 daidouzi add #4634
        );

        insert c1_1;

        CustomObject1__c c1_1_result = [select id,name,ownerId from CustomObject1__c where id=:c1_1.id];
        c1_1_result.Action__c = 'sphp_worldavenue';


		List<CustomObject1__c> clist = new List<CustomObject1__c>();
		clist.add(c1_1);

		Map<id, CustomObject1__c> cmap = new Map<id, CustomObject1__c> ();
		//第一引数：更新後の値、第二引数：更新前
		cmap.put(c1_1_result.id, c1_1_result);

		//所有者変更
    	//setReqOwner.setOwner(clist, cmap) ;
    	SetReqOwnerCustom.setOwner(clist, cmap) ;

    }
    public static testMethod void testSetOwner021() {
        List<CustomObject1__c> newJobSeekerList = new List<Customobject1__c>();
        Map<Id,CustomObject1__c> oldJobSeekerMap = new Map<Id,CustomObject1__c>();

        CustomObject1__c objNewJobSeeker = new CustomObject1__c();
        objNewJobSeeker.Id = 'a06000000000000';
        objNewJobSeeker.Field16__c = '理学療法士（PT）';
        objNewJobSeeker.Field14__c = '学生';

        newJobSeekerList.add(objNewJobSeeker);
        oldJobSeekerMap.put(objNewJobSeeker.Id,objNewJobSeeker);

        SetReqOwnerCustom.setOwnerWithin60day(newJobSeekerList,oldJobSeekerMap);
    }

    private static void createTestDateOrganizationSetting00(){
        
        if(OrganizationSettings__c.getInstance() != null){
            return;
        }

		// カスタム設定登録
		OrganizationSettings__c os = new OrganizationSettings__c(
			JobSeekerSynchronizationDate__c = -3
			,CandidateCulcInsertFlag__c = true
		);

		insert os;
    }


    private static testMethod void testCreateAlertMail(){
          EmailTemplate emailTemplate = createEmailTemplate ();
          test.startTest();
          SetReqOwnerCustom.createAlertMail(emailTemplate, new CustomObject1__c(), new User());
          test.stopTest();
    }

    private static EmailTemplate createEmailTemplate () {
        
        List <Folder> folderList = [SELECT Id FROM Folder Where DeveloperName = 'SearchSystemFolder'];
        Folder folder = null;
        if (!folderList.isEmpty()) {
            folder = folderList.get(0);
        }
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        EmailTemplate record = new EmailTemplate ();
        
        System.runAs (thisUser) {
            record.Name = 'test template';
            record.body = 'body';
            record.DeveloperName = 'deveploperName';
            record.FolderId = folder.Id;
            record.Subject = 'subject';
            record.TemplateType = 'text';
            insert record;
        }
        return record;
    }
}