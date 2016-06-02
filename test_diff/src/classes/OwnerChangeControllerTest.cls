/**
* 2013/09/13 daidouzi add
* OwnerChangeControllerのテストクラス。
 */
@isTest
private class OwnerChangeControllerTest {

    static testMethod void myUnitTest() {

		createTestDateOrganizationSetting();

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
            system.debug('求職者Id=' + c.Id);
        }

		//紐付け先の（扶養内）求職者を作成する。
		Candidate_Dependents__c CandidateDependents01 = new Candidate_Dependents__c(
			Name = '（扶養内）求職者太郎',
			candidate_name__c = cn[0].Id,	//求職者
			chusyutsu_route__c = 'testRec001',		//（検索用）エントリー手段
			teian_shubetsu__c = 'testRec002'		//（検索用）条件マッチ度
		);

		insert CandidateDependents01;


        //変更する所有者名取得
        String ownerName = OwnerChangeController.getOwnerName(cn[0].id, '1');
        //setReqOwnerのテストクラスで所有者変更のテストを行っているため、このテストクラスでは、null以外を評価に使用する
        System.assertNotEquals(ownerName, null, ownerName);

        //所有者変更
        String message = OwnerChangeController.changeOwner(cn[0].id, '1');
        //messageのメッセージ内容は変更予定のため、null以外の評価を使用する
        System.assertNotEquals(message, null, message);


       	//所有者名取得
        String ownerName2 = OwnerChangeController.getOwnerName(cn[0].id, '2');
        //setReqOwnerのテストクラスで所有者変更のテストを行っているため、このテストクラスでは、null以外を評価に使用する
        System.assertNotEquals(ownerName2, null, ownerName2);
        //所有者変更
        String message2 = OwnerChangeController.changeOwner(cn[0].id, '2');
        //messageのメッセージ内容は変更予定のため、null以外の評価を使用する
        System.assertNotEquals(message2, null, message2);

       	//所有者名取得
        String ownerName3 = OwnerChangeController.getOwnerName(cn[0].id, '3');
        //setReqOwnerのテストクラスで所有者変更のテストを行っているため、このテストクラスでは、null以外を評価に使用する
        System.assertNotEquals(ownerName3, null, ownerName3);
        //所有者変更
        String message3 = OwnerChangeController.changeOwner(cn[0].id, '3');
        //messageのメッセージ内容は変更予定のため、null以外の評価を使用する
        System.assertNotEquals(message3, null, message3);

    }

    static testMethod void myUnitTest2() {

		createTestDateOrganizationSetting();

        //変更する所有者名取得
        String ownerName = OwnerChangeController.getOwnerName(null, '1');
        System.assert(ownerName==null, ownerName);
        //所有者変更
        String message = OwnerChangeController.changeOwner(null, '1');
        System.assertNotEquals(message, null, message);

    }

    private static void createTestDateOrganizationSetting(){

		// カスタム設定登録
		OrganizationSettings__c os = new OrganizationSettings__c(
			JobSeekerSynchronizationDate__c = -3
			,CandidateCulcInsertFlag__c = true
			//,NewAllocationLogic__c = true
			//,NewAllocationLogicCustom__c = true
		);

		insert os;
    }

}