/*
* 2013/09/11 daidouzi add
* 所有者を変更する。
* 求職者のカスタムボタンから実行される。
*/
global class OwnerChangeController {
	/*
	typeが1の場合は扶養内
	typeが2の場合はFCC
	typeが3の場合は常勤

	⇒扶養内
		★希望雇用形態項目 = 非常勤
		転職希望時期（選択リスト）項目 = 3か月以内
	⇒FCC
		★希望雇用形態項目 = 常勤
		転職希望時期（選択リスト）項目 = 12か月以内
	⇒常勤
		★希望雇用形態項目 = 常勤
		転職希望時期（選択リスト）項目 = 3か月以内

	*/

	/**
	* 所有者を取得する。
	*
	*/
    webService static String getOwnerName(String id, String type){

		System.debug('----getOwnerName---'+id);
		System.debug('----type---'+type);


		//求職者を取得する
		List<CustomObject1__c> customObject1List = getCustomObject1List(id);
		String ownerName = null;

		if(customObject1List.size() != 0){

			/* 2014/7/30 daidouzi delete #3129
			//扶養内の場合
			if(type == '1'){
				//所有者変更処理開始
				setRepOwnerExecute(customObject1List, '非常勤', '3か月以内');
				//所有者変更処理開始
				//setRepOwnerExecute(customObject1List, '常勤', '3か月以内');

			//FCCの場合
			} else if(type == '2'){
				//所有者変更処理開始
				setRepOwnerExecute(customObject1List, '常勤', '12か月以内');
				//所有者変更処理開始
				//setRepOwnerExecute(customObject1List, '非常勤', '3か月以内');

			//常勤の場合
			} else if(type == '3'){
				//所有者変更処理開始
				setRepOwnerExecute(customObject1List, '常勤', '3か月以内');
				//所有者変更処理開始
				//setRepOwnerExecute(customObject1List, '常勤', '12か月以内');
			}
			*/

			//2014/7/30 daidouzi add start #3129
			//新ロジック
			//扶養内の場合
			if(type == '1'){
				//所有者変更処理開始
				setRepOwnerExecuteCustom(customObject1List, '扶養内');

			//FCCの場合
			} else if(type == '2'){
				//所有者変更処理開始
				setRepOwnerExecuteCustom(customObject1List, 'FCC');

			//常勤の場合
			} else if(type == '3'){
				//所有者変更処理開始
				setRepOwnerExecuteCustom(customObject1List, '常勤');

			//2015/3/23 daidouzi add start #4940
			//常勤の場合。扶養内求職者のカスタムボタンから実行される
			} else if(type == '4'){
				//所有者変更処理開始
				setRepOwnerExecuteCustom(customObject1List, '常勤');
			}
			//2015/3/23 daidouzi add end #4940

			//2014/7/30 daidouzi add end #3129


			//所有者取得
			String ownerid= customObject1List[0].Ownerid;
			//ユーザかキューか判定
			String objectName = getObjectNameByRelationFiledId(ownerid);

			System.debug('----objectName---'+objectName);

			//ownernameを取得
			//ownerName = getOwnerNameByUserGrop(objectName, ownerid);

			try{
				//ownernameを取得
				ownerName = getOwnerNameByUserGrop(objectName, ownerid);
			}catch(Exception e){
				ownerName = 'エラーが発生しました。再度処理を行ってください。または、システム管理者に連絡してください。\n'+e.getMessage();
			}

		}

	    return ownerName;
    }

	/**
	* 所有者を変更し、求職者オブジェクトを更新する。
	* 扶養内(type=1)の場合は関連する(扶養内)求職者オブジェクトの所有者を変更する
	*
	*/
    webService static String changeOwner(String id, String type){

		System.debug('----getOwnerName---'+id);
		System.debug('----type---'+type);

		//求職者を取得する
		List<CustomObject1__c> customObject1List = getCustomObject1List(id);

		String ownerName = null;

		if(customObject1List.size() != 0){

			/* 2014/7/30 daidouzi delete #3129
			//扶養内の場合
			if(type == '1'){
				//所有者変更処理開始
				setRepOwnerExecute(customObject1List, '非常勤', '3か月以内');
				//所有者変更処理開始
				//setRepOwnerExecute(customObject1List, '常勤', '3か月以内');

			//FCCの場合
			} else if(type == '2'){
				//所有者変更処理開始
				setRepOwnerExecute(customObject1List, '常勤', '12か月以内');
				//所有者変更処理開始
				//setRepOwnerExecute(customObject1List, '非常勤', '3か月以内');

			//常勤の場合
			} else if(type == '3'){
				//所有者変更処理開始
				setRepOwnerExecute(customObject1List, '常勤', '3か月以内');
				//所有者変更処理開始
				//setRepOwnerExecute(customObject1List, '常勤', '12か月以内');
			}
			*/

			//2014/7/30 daidouzi add start #3129
			//新ロジック
			//扶養内の場合
			if(type == '1'){
				//所有者変更処理開始
				setRepOwnerExecuteCustom(customObject1List, '扶養内');

			//FCCの場合
			} else if(type == '2'){
				//所有者変更処理開始
				setRepOwnerExecuteCustom(customObject1List, 'FCC');

			//常勤の場合
			} else if(type == '3'){
				//所有者変更処理開始
				setRepOwnerExecuteCustom(customObject1List, '常勤');

			//2015/3/23 daidouzi add start #4940
			//常勤の場合。扶養内求職者のカスタムボタンから実行される
			} else if(type == '4'){
				//所有者変更処理開始
				setRepOwnerExecuteCustom(customObject1List, '常勤');
			}
			//2015/3/23 daidouzi add end #4940

			//2014/7/30 daidouzi add end #3129
		}

		//savepoint
		Savepoint sp = Database.setSavepoint();

		String message = '所有者変更しました。';
		try{
			//【掘起しDM】所有所変更フラグ
			//del_start_2016/02/15 ogino #9551
			//customObject1List[0].DM_owner_chg_flag__c = '画面から所有者変更';
			//del_end_2016/02/15 ogino #9551

			//2015/3/23 daidouzi add start #4940
			//扶養内求職者のカスタムボタンから実行される
			if(type == '4'){

				//// ステータス更新
				customObject1List[0].Field3__c = '仮登録';
				// アクティブ発見に至った経路更新
				customObject1List[0].Field437__c='（NJB用）扶養内受け渡し';

			}
			//2015/3/23 daidouzi add end #4940
			//add_start_2016/02/15 ogino #9564
			if(
				type == '3'
				|| type == '4'
			){
				customObject1List[0].active_judge_type__c = '未面談';
				customObject1List[0].Field3__c = '仮登録';
				customObject1List[0].non_active_type__c = '';
				customObject1List[0].ng_route__c = '';
				customObject1List[0].nonactived__c = null;
			}
			//add_end_2016/02/15 ogino #9564

			update customObject1List;

			//2015/3/5 daidouzi add #4634
			System.debug('---所有者にメール送信----');

			//--------------------------------
			//メール送信
			//--------------------------------
			//割り振り、担当者あり宛、その他の割り振りロジック。 beforeで設定した情報を取得
			Map<String, List<User>> userListForAllocation = Utility.getUserListForAllocation();
			//担当エリア その他アドレス割り振り
 			Map<String, List<String>> userListForTantouArea = Utility.getUserListForTantouArea();
			//割り振り処理。所有者にメール送信----------------
			SetReqOwnerCustom.sendForAllocation(userListForAllocation);
			//担当エリア その他アドレス割り振り
			SetReqOwnerCustom.sendForForTantouArea(userListForTantouArea);
			//2015/3/5 daidouzi add end #4634

			//扶養内の場合
			if(type == '1'){

				System.debug('---(扶養内)求職者を更新します----' + type);

				//求職者に関連する(扶養内)求職者を取得する
				List<Candidate_Dependents__c> candidateDependentsList = getCandidateDependentsList(customObject1List[0].id);

				System.debug('----candidateDependentsList---'+candidateDependentsList);

				//非常勤担当者名に求職者の所有者を設定する
				updateCandidateDependentsList(candidateDependentsList, customObject1List[0].OwnerId);

			//2015/3/23 daidouzi add start #4940
			//扶養内求職者のカスタムボタンから実行される
			} else if(type == '4'){

				System.debug('---(扶養内)求職者を更新します---扶養内求職者のカスタムボタンから実行される-' + type);

				//求職者に関連する(扶養内)求職者を取得する
				List<Candidate_Dependents__c> candidateDependentsList = getCandidateDependentsList(customObject1List[0].id);
				//扶養内求職者の項目を設定する
				updateCandidateDependentsForCandidateDependents(candidateDependentsList, customObject1List[0].OwnerId);
			}
			//2015/3/23 daidouzi add end #4940


		}catch(Exception e){
			//ロールバック
			Database.rollback(sp);
			message = 'エラーが発生しました。再度処理を行ってください。または、システム管理者に連絡してください。\n'+e.getMessage();
		}

        return message;
    }

	/**
	 * 所有者変更処を行う。改修版
	 * 一旦判定項目に値を入れて処理終了後に元に戻す。
	 */
	private static void setRepOwnerExecuteCustom(List<CustomObject1__c> customObject1List, String selectValue){

		//更新前の値を保持
		CustomObject1__c tempJs = new CustomObject1__c(
			//★希望職種項目
			Field16__c = customObject1List[0].Field16__c
			//★都道府県
			,Field6__c = customObject1List[0].Field6__c
			//市区町村
			,Field7__c = customObject1List[0].Field7__c
			//詳細住所（市区町村以下）
			,Field21__c = customObject1List[0].Field21__c
			//★希望雇用形態
			,Field17__c = customObject1List[0].Field17__c //2014/8/18 daidouizi add #3254
		);

		//----所有者変更に必要な値を設定する。後で元の値に戻す-----

		//登録サイトをNJBにするためc.Field16__c「看護師（正看・准看）」を設定する
		customObject1List[0].Field16__c = '看護師（正看・准看）';

		//所有者変更に使用する住所を設定。編集用を優先する
		if(customObject1List[0].StateEdit__c != null && customObject1List[0].StateEdit__c != ''){
			//★都道府県
			customObject1List[0].Field6__c = customObject1List[0].StateEdit__c;  //都道府県(編集用)
		}
		if(customObject1List[0].StateEdit__c != null && customObject1List[0].StateEdit__c != ''){
			//市区町村
			customObject1List[0].Field7__c = customObject1List[0].CityEdit__c;  //市区町村(編集用)
		}
		if(customObject1List[0].StateEdit__c != null && customObject1List[0].StateEdit__c != ''){
			//詳細住所（市区町村以下）
			customObject1List[0].Field21__c = customObject1List[0].Field180__c;  //詳細住所（市区町村以下）(編集用)
		}

		//★希望雇用形態
		customObject1List[0].Field17__c = '常勤';//2014/8/18 daidouizi add #3254

		System.debug('----customObject1List[0]-１--'+customObject1List[0]);

		//所有者変更処理
		SetReqOwnerCustom.setOwnerRunForPage(customObject1List,selectValue);

		//値を戻す
		customObject1List[0].Field16__c = tempJs.Field16__c;
		customObject1List[0].Field6__c = tempJs.Field6__c;
		customObject1List[0].Field7__c = tempJs.Field7__c;
		customObject1List[0].Field21__c = tempJs.Field21__c;
		customObject1List[0].Field17__c = tempJs.Field17__c;//2014/8/18 daidouizi add #3254


		System.debug('----customObject1List[0]-２--'+customObject1List[0]);

	}




	/**
	 *(扶養内)求職者オブジェクトの非常勤担当者名に求職者の所有者を設定し更新する。
	 *
	 */
	private static void updateCandidateDependentsList(List<Candidate_Dependents__c> candidateDependentsList, ID OwnerId){

		if(candidateDependentsList.size() > 0){

			//ユーザかキューか判定
			String objectName = getObjectNameByRelationFiledId(OwnerId);

			//所有者がユーザの場合
			if(objectName == 'User'){

				//非常勤担当者名変更する
				for(Candidate_Dependents__c candidateDependents :candidateDependentsList){

					//非常勤担当者名に求職者の所有者を設定する
					candidateDependents.fuyounai_hijoukintantousyamei__c = OwnerId;
				}

				System.debug('-------'+candidateDependentsList);
				//更新する
				update candidateDependentsList;  //エラー処理は呼び出し元で行う
			}
		}
	}

	/**
	 * (扶養内)求職者を取得する。
	 *
	 */
	private static List<Candidate_Dependents__c> getCandidateDependentsList(Id id){

		//(扶養内)求職者を取得する
		List<Candidate_Dependents__c> candidateDependentsList = null;
		candidateDependentsList = [
			select
				id
				,name
				,fuyounai_hijoukintantousyamei__c  //非常勤担当者名
			from Candidate_Dependents__c
			where
				candidate_name__c =:id
		];

		return candidateDependentsList;

	}


	/**
	* ユーザ、キューの名前を取得する。
	*/
	private static String getOwnerNameByUserGrop(String objectName, String ownerid){
		String ownerName = null;

		if(objectName == 'User'){
			User userObj = [select id, name from User where id=:ownerid];
			ownerName = userObj.name;
		}else if(objectName == 'Group'){
			Group groupObj = [select id, name from Group where id=:ownerid];
			ownerName = groupObj.name;
		}
		return ownerName;
	}

	/**
	* 求職者オブジェクトを取得する。
	*/
    private static List<CustomObject1__c> getCustomObject1List(String id){

    	//CustomObject1__cのfieldを取得
        Map<String,Map<String,String>> cbFieldMap = new Map<String,Map<String,String>>();
        Map<String, Schema.SObjectField> cbFieldInfoMap = Schema.getGlobalDescribe().get('CustomObject1__c').getDescribe().fields.getMap();
        List<String> cbFieldList=new List<String>();
        //項目の情報を格納
        for(String field : cbFieldInfoMap.keySet()){
            cbFieldMap.put(
                cbFieldInfoMap.get(field).getDescribe().getName(),
                new Map<String, String>{
                    'isUpdateable' => String.valueOf(cbFieldInfoMap.get(field).getDescribe().isUpdateable()),
                    'isNillable' => String.valueOf(cbFieldInfoMap.get(field).getDescribe().isNillable()),
                    'type' => String.valueOf(cbFieldInfoMap.get(field).getDescribe().getType())
                }
            );
            //全ての項目から編集可能な項目のみ抽出し、格納する
            if(cbFieldInfoMap.get(field).getDescribe().isUpdateable()){
                cbFieldList.add(cbFieldInfoMap.get(field).getDescribe().getName());
            }
        }

        String jueryString = 'select ' + String.Join(cbFieldList, ',') + ',Owner.name from CustomObject1__c where id=:id';

		//クエリ実行
		List<CustomObject1__c> customObject1List = Database.query(jueryString);
		System.debug('----customObject1List---'+customObject1List);

    	return customObject1List;
    }

	//globalDescribe
	private static Map<String, Schema.SObjectType> globalDescribe {
		get{
			if(globalDescribe == null){
				globalDescribe = Schema.getGlobalDescribe();
			}
			return globalDescribe;
		}
		set;
	}

	//リレーションフィールドのprefixからオブジェクト名を
	private static String getObjectNameByRelationFiledId(String objectId){
		String objName;
		//先頭から3文字
		String headFiled = objectId.substring(0, 3);
		//System.debug('★headFiled='+headFiled);
	    for (Schema.SObjectType stypekey : globalDescribe.values()) {
			String prefix = stypekey.getDescribe().getKeyPrefix();
			//プレフィックス名と一致
			if( headFiled == prefix){
				objName = stypekey.getDescribe().getName();
				break;
			}
	    }
		return objName;
	}

	/**
	 * (扶養内)求職者オブジェクトの項目を更新する。
	 * 2015/3/23 daidouzi add end #4940
	 */
	private static void updateCandidateDependentsForCandidateDependents(List<Candidate_Dependents__c> candidateDependentsList, ID OwnerId){

		System.debug('---updateCandidateDependentsForCandidateDependents----');

		if(candidateDependentsList.size() > 0){

			//扶養内求職者のステータスを更新する。
			for(Candidate_Dependents__c candidateDependentsObj : candidateDependentsList){
				////現状ステータス更新
				candidateDependentsObj.genjousutetasu__c='CCコラボ済';
			}

			update candidateDependentsList;
		}
	}

	/**
	 * 所有者変更処を行う。削除対象*************:
	 * 一旦判定項目に値を入れて処理終了後に元に戻す。
	 */
	 /*
	private static void setRepOwnerExecute(List<CustomObject1__c> customObject1List, String Field17, String Field142 ){

		CustomObject1__c tempJs = new CustomObject1__c(
			//★希望雇用形態
			Field17__c = customObject1List[0].Field17__c,
			//転職希望時期（選択リスト）
			Field142__c = customObject1List[0].Field142__c,
			//求職者ID取得CC（ユーザーＩＤ)
			CC_form_user_id__c = customObject1List[0].CC_form_user_id__c
		);

		customObject1List[0].Field17__c = Field17;
		customObject1List[0].Field142__c = Field142;
		customObject1List[0].CC_form_user_id__c = null;


		//登録サイトをNJBにするためc.Field16__c「看護師（正看・准看）」を設定する

			System.debug('----customObject1List[0]-１--'+customObject1List[0]);

		//所有者変更処理
		setReqOwner.setOwner(customObject1List);

		customObject1List[0].Field17__c = tempJs.Field17__c;
		customObject1List[0].Field142__c = tempJs.Field142__c;
		customObject1List[0].CC_form_user_id__c = tempJs.CC_form_user_id__c;

		System.debug('----customObject1List[0]-２--'+customObject1List[0]);

	}
	*/


}