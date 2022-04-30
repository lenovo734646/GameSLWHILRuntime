using AssemblyCommon;
using DG.Tweening;
using Hotfix.Common;
using LitJson;
using Spine.Unity;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Hotfix.SLWH
{
	public enum eAnimal
	{
		Loin = 0,
		Panda = 1,
		Monkey = 2,
		Rabbit = 3,
	}

	public enum eAniColor
	{
		Red = 0,
		Yellow = 1,
		Green = 2,
		Gray = 4,
	}

	public enum eAwardsType
	{
		RLion,
		YLion,
		GLion,
		RPanda,
		YPanda,
		GPanda,
		RMonkey,
		YMonkey,
		GMonkey,
		RRabbit,
		YRabbit,
		GRabbit,

		DaSanYuanLion = 100,
		DaSanYuanPanda,
		DaSanYuanMonkey,
		DaSanYuanRabbit,

		DaSiXiRed = 200,
		DaSiXiYellow,
		DaSiXiGreen,

		Lightingx2 = 301,
		Lightingx3,

		SongDeng = 400,
		CaiJing = 500,

		Big = 600,
		Draw,
		Small
	}

	public class BetItem
	{
		public BetItem(ViewGameScene v, int betID)
		{
			mainV_ = v;
			betID_ = betID;
			Init_();
		}

		public void SetMybet(long bet)
		{
			var txt = txtObj_.FindChildDeeply("selfScore").GetComponent<TextMeshProUGUI>();
			txt.text = bet.ToString();
		}

		public void SetTotalBet(long bet)
		{
			var txt = txtObj_.FindChildDeeply("totalScore").GetComponent<TextMeshProUGUI>();
			txt.text = bet.ToString();
		}

		public void SetFactor(long bet)
		{
			var txt = txtObj_.FindChildDeeply("ratioText").GetComponent<TextMeshProUGUI>();
			txt.text = bet.ToString();
		}

		void Init_()
		{
			//服务器BetID映射到UI名字上
			Dictionary<int, int> mapid = new Dictionary<int, int>();
			mapid.Add(0, 1); mapid.Add(1, 5); mapid.Add(2, 9);
			mapid.Add(3, 2); mapid.Add(4, 6); mapid.Add(5, 10);
			mapid.Add(6, 3); mapid.Add(7, 7); mapid.Add(8, 11);
			mapid.Add(9, 4); mapid.Add(10, 8); mapid.Add(11, 12);
			mapid.Add(12, 13); mapid.Add(13, 14); mapid.Add(14, 15);

			int objID = mapid[betID_];

			anmiObj_ = mainV_.BetStageRoot.FindChildDeeply($"XiazhuAnniu_{objID}");
			objBtn_ = mainV_.BetStageRoot.FindChildDeeply("ButtonRoot").FindChildDeeply($"{objID}");
			txtObj_ = mainV_.BetStageRoot.FindChildDeeply("TextRoot").FindChildDeeply($"{objID}");

			var btn = objBtn_.GetComponent<Button>();
			btn.onClick.AddListener(()=> {
				anmiObj_.StartAnim();
				anmiObj_.StartParticles();


			});
		}

		int betID_;
		GameObject anmiObj_, objBtn_, txtObj_;
		ViewGameScene mainV_;
	}

	public class Jewel
	{
		public Jewel(ViewGameScene v, GameObject obj)
		{
			mainV_ = v;
			obj_ = obj;
		}

		public void SetColor(int c)
		{
			color_ = (eAniColor)c;
			var render = obj_.GetComponent<MeshRenderer>();
			if(color_ == eAniColor.Red)
				render.material = mainV_.matRed;
			else if(color_ == eAniColor.Yellow)
				render.material = mainV_.matYellow;
			else if (color_ == eAniColor.Green)
				render.material = mainV_.matGreen;
			else if (color_ == eAniColor.Gray)
				render.material = mainV_.matRed;
		}

		public void Blink()
		{
			if (color_ == eAniColor.Red)
				obj_.StartAnim("BaoshiFlash_1");
			else if (color_ ==eAniColor.Yellow)
				obj_.StartAnim("BaoshiFlash_3");
			else
				obj_.StartAnim("BaoshiFlash_2");
		}

		public void StopBlink()
		{
			obj_.StartAnim("BaoshiFlash");
		}

		GameObject obj_;
		ViewGameScene mainV_;
		eAniColor color_;
	}

	public class Animal
	{
		enum State
		{
			None,
			Idle,
			Jump,
			Dance,
			Round,

		}

		public Animal(GameObject obj, int index, GameObject jumpTarget)
		{
			obj_ = obj;
			jumpTar_ = jumpTarget;
			transformOld_ = obj_.transform;
			idles.Add("Idel"); idles.Add("Idel1");
			animal = (eAnimal)(index % 4);
			animal = (eAnimal)(index % 4);
			animal = (eAnimal)(index % 4);
		}

		public IEnumerator JumpToStage()
		{
			//跳上舞台
			PlayJump();
			var jump = obj_.transform.DOJump(jumpTar_.transform.position, 2, 1, 0.5f);
			yield return jump.WaitForCompletion();

			//转身
			RoundBody();
			var rot = obj_.transform.DOLocalRotate(new Vector3(0, -180, 0), 0.3f);
			yield return rot.WaitForCompletion();

			//跳舞
			PlayDance();

		}

		public IEnumerator JumpBack()
		{
			//转身准备跳回原来位置
			RoundBody();
			var tPos = transformOld_.position;
			tPos.y = obj_.transform.position.y;
			var lookAt = obj_.transform.DOLookAt(tPos, 0.3f);
			yield return lookAt.WaitForCompletion();

			//跳回
			PlayJump();
			var jump = obj_.transform.DOJump(transformOld_.position, 2, 1, 0.5f);
			yield return jump.WaitForCompletion();

			//转回原始朝向
			RoundBody();
			var tPos2 = jumpTar_.transform.position;
			tPos2.y = obj_.transform.position.y;
			var lookAt2 = obj_.transform.DOLookAt(tPos2, 0.3f);
			yield return lookAt2.WaitForCompletion();

			PlayIdle();
		}


		public void PlayJump()
		{
			st = State.Jump;
			obj_.StartAnim("Jump");
		}

		public void PlayIdle()
		{
			st = State.Idle;
			obj_.StartAnim("Idel");
			idleTimer.Restart();

		}

		public void PlayDance()
		{
			st = State.Dance;
			obj_.StartAnim("Victory");
		}

		public void Update()
		{
			if(idleTimer.Elapse() >= 2.0f && st == State.Idle) {
				idleTimer.Restart();
				PlayIdle();
			}
		}

		public void RoundBody()
		{
			st = State.Round;
			if (animal == eAnimal.Loin) {
				obj_.StartAnim("Round_Lion");
			}
			else if(animal == eAnimal.Panda) {
				obj_.StartAnim("round_Panda");
			}
			else if (animal == eAnimal.Rabbit) {
				obj_.StartAnim("Round_Rabbit");
			}
			else if (animal == eAnimal.Monkey) {
				obj_.StartAnim("Round_Monkey");
			}
		}

		GameObject obj_, jumpTar_;
		Transform transformOld_;
		List<string> idles = new List<string>();
		TimeCounter idleTimer = new TimeCounter("idleTimer");
		State st = State.None;
		public eAnimal animal;

	}

	public class ViewGameScene : ViewMultiplayerScene
	{
		public ViewGameScene()
		{
			var gm = (GameControllerMultiplayer)AppController.ins.currentApp.game;
			gm.mainView = this;
		}

		protected override void SetLoader()
		{
			var ctrl = (GameController)AppController.ins.currentApp.game;
			LoadScene("Assets/Res/Games/SLWH/Scenes/MainScene.unity", null);

			{
				var tsk = new ViewLoadTask<Material>();
				tsk.assetPath = "Assets/Res/Games/SLWH/Dance/Secne_Model/ColorLight/light_Red.mat";
				tsk.callback = (t) => {
					matRed = t;
				};
			}
			{
				var tsk = new ViewLoadTask<Material>();
				tsk.assetPath = "Assets/Res/Games/SLWH/Dance/Secne_Model/ColorLight/light_Green.mat";
				tsk.callback = (t) => {
					matGreen = t;
				};
			}
			{
				var tsk = new ViewLoadTask<Material>();
				tsk.assetPath = "Assets/Res/Games/SLWH/Dance/Secne_Model/ColorLight/light_Yellow.mat";
				tsk.callback = (t) => {
					matGreen = t;
				};
			}
		}

		protected override IEnumerator OnResourceReady()
		{
			yield return base.OnResourceReady();

			Globals.resLoader.LoadAsync<GameObject>("Assets/Res/Games/SLWH/Dance/UI/Result/animalLion.prefab", 
				(t) => {
				cachedLion_ = t;
			}, null);

			Globals.resLoader.LoadAsync<GameObject>("Assets/Res/Games/SLWH/Dance/UI/Result/animalMonky.prefab", 
				(t) => {
				cachedMonkey_ = t;
			}, null);

			Globals.resLoader.LoadAsync<GameObject>("Assets/Res/Games/SLWH/Dance/UI/Result/animalPanda.prefab",
				(t) => {
				cachedPanda_ = t;
			}, null);

			Globals.resLoader.LoadAsync<GameObject>("Assets/Res/Games/SLWH/Dance/UI/Result/animalRabbit.prefab", 
				(t) => {
				cachedRabbit_ = t;
			}, null);

			Globals.resLoader.LoadAsync<GameObject>("Assets/Res/Games/SLWH/Dance/UI/Result/animalLion_Gold.prefab",
				(t) => {
				cacheLionGold_ = t;
			}, null);

			Globals.resLoader.LoadAsync<GameObject>("Assets/Res/Games/SLWH/Dance/UI/Result/animalMonky_Gold.prefab",
				(t) => {
				cachedMonkeyGold_ = t;
			}, null);
			Globals.resLoader.LoadAsync<GameObject>("Assets/Res/Games/SLWH/Dance/UI/Result/animalPanda_Gold.prefab",
				(t) => {
					cachedPandaGold_ = t;
			}, null);

			Globals.resLoader.LoadAsync<GameObject>("Assets/Res/Games/SLWH/Dance/UI/Result/animalRabbit_Gold.prefab",
				(t) => {
				cachedRabbitGold_ = t;
			}, null);

			Globals.resLoader.LoadAsync<Texture2D>("Assets/Res/Games/SLWH/Dance/UI/Result/color_1.png",
				(t) => {
					cachedRedColor_ = t;
				}, null);

			Globals.resLoader.LoadAsync<Texture2D>("Assets/Res/Games/SLWH/Dance/UI/Result/color_2.png",
				(t) => {
					cachedGreenColor_ = t;
				}, null);
			Globals.resLoader.LoadAsync<Texture2D>("Assets/Res/Games/SLWH/Dance/UI/Result/color_3.png",
				(t) => {
					cachedYellowColor_ = t;
				}, null);

			yield return Globals.resLoader.WaitForAllTaskCompletion();
			canvas = GameObject.Find("Canvas");

			resultPanel = canvas.FindChildDeeply("ResultPanel");
			BetStageRoot = GameObject.Find("BetStageRoot");
			animalRot = GameObject.Find("Animal_Rotate_Root");
			arrowRot = GameObject.Find("Arrow_Rotate_Root");
			jumpTarget = animalRot.FindChildDeeply("JumpTarget");

			var animalIndexs = animalRot.FindChildDeeply("animalIndexs");

			var ColorLightRoot = GameObject.Find("ColorLightRoot");
			for (int i = 1; i <= 24; i++) {
				var obj = ColorLightRoot.FindChildDeeply($"{i}");
				var jew = new Jewel(this, obj);
				jewels_.Add(jew);
			}

			//动物站位分配
			float initDegree = 15 * 360.0f / 24;
			for (int i = 1; i <= 24; i++) {
				GameObject obj;
				//设置位置
				if(i < 10)
					obj = animalIndexs.FindChildDeeply($"0{i}");
				else 
					obj = animalIndexs.FindChildDeeply($"{i}");

				float deg = Mathf.Deg2Rad * (initDegree - (360.0f / 24) * (i - 1));

				float x = Mathf.Cos(deg) * 16.0f;
				float z = Mathf.Sin(deg) * 16.0f;
				float y = 9.0f;
				obj.transform.position = new Vector3(x, y, z);
				var lookTo = jumpTarget.transform.position;
				lookTo.y = obj.transform.position.y;
				obj.transform.LookAt(lookTo);

				var animal = new Animal(obj, i - 1, jumpTarget);
				animals_.Add(animal);
				animal.PlayIdle();
			}

			for (int i = 0; i < 15; i++) {
				var bti = new BetItem(this, i);
				betItems_.Add(i, bti);
			}

			//百人类游戏直接进游戏房间
			var handle1 = AppController.ins.network.EnterGameRoom(1, 0);
			yield return handle1;
			if ((int)handle1.Current == 0) {
				ViewToast.Create(LangNetWork.EnterRoomFailed);
			}

		}


		public override void Close()
		{
			base.Close();
			jewels_.Clear();
			betItems_.Clear();

			cachedLion_.Release();
			cacheLionGold_.Release();
			cachedPanda_.Release();
			cachedPandaGold_.Release();
			cachedMonkey_.Release();
			cachedMonkeyGold_.Release();
			cachedRabbit_.Release();
			cachedRabbitGold_.Release();
			cachedGreenColor_.Release();
			cachedRedColor_.Release();
			cachedYellowColor_.Release();
		}

		public override void Update()
		{
			base.Update();
			for(int i = 0; i < animals_.Count; i++) {
				animals_[i].Update();
			}
		}

		public override void OnNetMsg(int cmd, string json)
		{
			switch(cmd) {
				case (int)GameMultiID.msg_send_color: {
					var msg = JsonMapper.ToObject<msg_send_color>(json);
					OnSendColor(msg);
				}
				break;
			}
		}

		IEnumerator DoSetColor(List<int> lst)
		{
			if (!AppController.ins.currentApp.game.isEntering) {
				foreach (var jew in jewels_) {
					jew.SetColor((int)eAniColor.Gray);
					yield return new WaitForSeconds(0.05f);
				}

				int i = 0;
				foreach (var jew in jewels_) {
					jew.SetColor(lst[i]);
					i++;
					yield return new WaitForSeconds(0.05f);
				}
			}
			else {
				int i = 0;
				foreach (var jew in jewels_) {
					jew.SetColor(lst[i]);
					i++;
				}
			}
		}

		private void OnSendColor(msg_send_color msg)
		{
			lstColor = Globals.Split(msg.colors_, ",");
			this.StartCor(DoSetColor(lstColor), true);

			lstRates = Globals.Split(msg.rates_, ",");
			var obj = BetStageRoot.FindChildDeeply("Canvas3D");
			obj = obj.FindChildDeeply("TextRoot");

			for(int i = 0; i < 12; i++) {
				BetItem bi = betItems_[i];
				bi.SetFactor(lstRates[i]);
			}

			MyDebug.LogFormat("Send Color:{0},  rates:{1}", msg.colors_, msg.rates_);
		}

		IEnumerator CountDown_(float t, Text txtCounter)
		{
			float tLeft = t;
			while(tLeft > 0) {
				tLeft -= 1.0f;
				yield return new WaitForSeconds(0.95f);
				if (tLeft < 0.0f) tLeft = 0.0f;
				txtCounter.text = tLeft.ToString();
			}
			yield return 0;
		}

		public override void OnStateChange(msg_state_change msg)
		{
			GameControllerBase.GameState st = (GameControllerBase.GameState)int.Parse(msg.change_to_);
			var txtCounter = canvas.FindChildDeeply("TimeCounter").FindChildDeeply("TimeText").GetComponent<Text>();
			var gameState_1 = canvas.FindChildDeeply("gameState_1");
			var gameState_2 = canvas.FindChildDeeply("gameState_2");
			var gameState_3 = canvas.FindChildDeeply("gameState_3");
			
			gameState_1.SetActive(false);
			gameState_2.SetActive(false);
			gameState_3.SetActive(false);

			if (st == GameControllerBase.GameState.state_wait_start) {
				gameState_1.SetActive(true);
				resultPanel.SetActive(false);
				BetStageRoot.StartDoTweenAnim(false);
			}
			else if (st == GameControllerBase.GameState.state_do_random) {
				gameState_2.SetActive(true);
				resultPanel.SetActive(false);
				BetStageRoot.StartDoTweenAnim(true);
			}
			else if (st == GameControllerBase.GameState.state_rest_end) {
				gameState_3.SetActive(true);
			}

			this.StartCor(CountDown_(int.Parse(msg.time_left), txtCounter), false);
		}

		public override void OnPlayerSetBet(msg_player_setbet msg)
		{
			var bi = betItems_[int.Parse(msg.present_id_)];
			bi.SetTotalBet(long.Parse(msg.max_setted_));
		}

		public override void OnMyBet(msg_my_setbet msg)
		{
			var bi = betItems_[int.Parse(msg.present_id_)];
			bi.SetMybet(long.Parse(msg.my_total_set_));
		}

		public override void OnPlayerEnter(msg_player_seat msg)
		{
			var pos = int.Parse(msg.pos_);
			if(AppController.ins.self.gamePlayer.serverPos == pos) {
				
			}
		}

		public override void OnPlayerLeave(msg_player_leave msg)
		{
			
		}

		IEnumerator DoRandomResult_(msg_random_result_base msg)
		{
			var pmsg = (msg_random_result_slwh)msg;

			//主中奖类型
			pidMain = (eAwardsType) int.Parse(pmsg.animal_pid_);
			pidSub = (eAwardsType)int.Parse(pmsg.bigsmall_);
			//副中奖类型
			int pidBigsmall = int.Parse(pmsg.bigsmall_);
			//中奖颜色
			int color = int.Parse(pmsg.color_);
			//中奖动物列表
			animalIDs = Globals.Split(pmsg.animals_, ",");

			//转转奖时间
			float aniTime = AppController.ins.currentApp.game.isEntering ? 1.0f : 5.0f;

			var tweenAnimal = animalRot.transform.DOLocalRotate(new Vector3(0, -720, 0), aniTime);
			tweenAnimal.SetEase(Ease.InOutQuad);

			for(int i = 0; i < animalIDs.Count; i++) {
				int animal = animalIDs[i];
				int rotUnit = 24 - lastPointerPos;
				rotUnit += animal;
				rotUnit += 24 * 2;
				
				var tween = arrowRot.transform.DOLocalRotate(new Vector3(0, rotUnit, 0), aniTime);
				tween.SetEase(Ease.InOutQuad);
				yield return tween.WaitForCompletion();

				lastPointerPos = animal;

				this.StartCor(animals_[animal].JumpToStage(), false);

				if (i != animalIDs.Count - 1) {
					yield return new WaitForSeconds(2.0f);
				}
				else {
					yield return new WaitForSeconds(5.0f);
				}
				this.StartCor(animals_[animal].JumpBack(), false);
			}
		}

		public override void OnRandomResult(msg_random_result_base msg)
		{
			this.StartCor(DoRandomResult_(msg), true);
		}

		public override void OnLastRandomResult(msg_last_random_base msg)
		{
			var pmsg = (msg_last_random_slwh)msg;

		}

		public override void OnBankDepositChanged(msg_banker_deposit_change msg)
		{
			
		}

		public override void OnBankPromote(msg_banker_promote msg)
		{
			
		}

		public override void OnGameReport(msg_game_report msg)
		{
			resultPanel.SetActive(true);
			bool bGold = pidMain >= eAwardsType.DaSanYuanLion;
			int ratio = 0;
			for (int i = 0; i < animalIDs.Count; i++) {
				eAnimal animal = animals_[animalIDs[i]].animal;
				eAniColor color = (eAniColor)lstColor[animalIDs[i]];
				ratio = lstRates[animalIDs[i]];
				GameObject objAnimal;
				
				if(animal == eAnimal.Loin) {
					if (bGold)
						objAnimal = cacheLionGold_.Instantiate();
					else
						objAnimal = cachedLion_.Instantiate();
				}
				else if(animal == eAnimal.Monkey){
					if (bGold)
						objAnimal = cachedMonkeyGold_.Instantiate();
					else
						objAnimal = cachedMonkey_.Instantiate();
				}
				else if(animal == eAnimal.Panda) {
					if (bGold)
						objAnimal = cachedPandaGold_.Instantiate();
					else
						objAnimal = cachedPanda_.Instantiate();
				}
				else {
					if (bGold)
						objAnimal = cachedRabbitGold_.Instantiate();
					else
						objAnimal = cachedRabbit_.Instantiate();
				}

				var objColor = objAnimal.FindChildDeeply("color").GetComponent<Image>();
				var ratioTxt = objAnimal.FindChildDeeply("ratioText").GetComponent<TextMeshProUGUI>();
				ratioTxt.text = lstRates[i].ToString();

				var rect = objColor.GetComponent<RectTransform>().rect;
				var pivot = new Vector2(0.5f, 0.5f);
				if (color == eAniColor.Red) {
					objColor.sprite = Sprite.Create(cachedRedColor_.Result, rect, pivot);
				}
				else if(color == eAniColor.Green) {
					objColor.sprite = Sprite.Create(cachedGreenColor_.Result, rect, pivot);
				}
				else
					objColor.sprite = Sprite.Create(cachedYellowColor_.Result, rect, pivot);
			}
			var spine_stage = resultPanel.FindChildDeeply("spine_stage");
			var sk = spine_stage.GetComponent<SkeletonGraphic>();
			sk.AnimationState.SetAnimation(0, "animation", true);

			var betText = canvas.FindChildDeeply("betText").GetComponent<Text>();
			betText.text = msg.pay_;
			var winText = canvas.FindChildDeeply("winText").GetComponent<Text>();
			winText.text = msg.actual_win_;
			var winEnjoyGame = canvas.FindChildDeeply("winEnjoyGame");
			var winColorBG_1 = winEnjoyGame.FindChildDeeply("winColorBG_1");
			var winColorBG_2 = winEnjoyGame.FindChildDeeply("winColorBG_2");
			var winColorBG_3 = winEnjoyGame.FindChildDeeply("winColorBG_3");
			winColorBG_1.SetActive(false); 
			winColorBG_2.SetActive(false); 
			winColorBG_3.SetActive(false);
			var ratio2 = winEnjoyGame.FindChildDeeply("ratioText").GetComponent<TextMeshProUGUI>();
			if (pidSub == eAwardsType.Big) {
				winColorBG_1.SetActive(true);
				ratio2.text = "X2";
			}
			else if(pidSub == eAwardsType.Small) {
				winColorBG_3.SetActive(true);
				ratio2.text = "X2";
			}
			else {
				winColorBG_2.SetActive(true);
				ratio2.text = "X12";
			}

			var winAnimal = resultPanel.FindChildDeeply("winAnimal");
			var winSanYuan = resultPanel.FindChildDeeply("winSanYuan");
			var winSiXi = resultPanel.FindChildDeeply("winSiXi");
			var winShandian = resultPanel.FindChildDeeply("winShandian");
			var winCaiJin = resultPanel.FindChildDeeply("winCaiJin");
			var winSongDeng = resultPanel.FindChildDeeply("winSongDeng");
			winAnimal.SetActive(false);
			winSanYuan.SetActive(false);
			winSiXi.SetActive(false);
			winShandian.SetActive(false);
			winCaiJin.SetActive(false);
			winSongDeng.SetActive(false);

			if (pidMain >= eAwardsType.DaSanYuanLion && pidMain < eAwardsType.DaSiXiRed) {
				winSanYuan.SetActive(true);
			}
			else if (pidMain >= eAwardsType.DaSiXiRed && pidMain < eAwardsType.Lightingx2) {
				winSiXi.SetActive(true);
			}
			else if (pidMain == eAwardsType.SongDeng) {
				winSongDeng.SetActive(true);
			}
			else if (pidMain == eAwardsType.CaiJing) {
				winCaiJin.SetActive(true);
			}
			else {
				winAnimal.SetActive(true);
				var ratio3 = winAnimal.FindChildDeeply("ratioText").GetComponent<TextMeshProUGUI>();
				ratio3.text = "X" + ratio;
			}
		}

		public Material matRed, matGreen, matYellow;
		public GameObject BetStageRoot, animalRot, arrowRot, jumpTarget, canvas, resultPanel;

		List<Jewel> jewels_ = new List<Jewel>();
		List<Animal> animals_ = new List<Animal>();
		Dictionary<int, BetItem> betItems_ = new Dictionary<int, BetItem>();

		int lastPointerPos = 0;
		AddressablesLoader.LoadTask<GameObject> cachedLion_, cacheLionGold_, cachedPanda_, cachedPandaGold_, cachedMonkey_, cachedMonkeyGold_, cachedRabbit_, cachedRabbitGold_;
		AddressablesLoader.LoadTask<Texture2D> cachedRedColor_, cachedGreenColor_, cachedYellowColor_;
		List<int> lstColor, lstRates, animalIDs;
		eAwardsType pidMain, pidSub;
	}
}
