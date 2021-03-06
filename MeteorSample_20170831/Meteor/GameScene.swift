//
//  GameScene.swift
//
import UIKit
import SpriteKit
import AVFoundation
import AudioToolbox
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

@available(iOS 9.0, *)
class GameScene: SKScene, SKPhysicsContactDelegate {
    let debug = true   //デバッグフラグ
	//MARK: - 基本構成
    //MARK: ノード
    let baseNode = SKNode()                                         //ゲームベースノード
    let playerBaseNode = SKNode()                                   //プレイヤーベース
    let backScrNode = SKNode()                                      //背景ノード
    let titleLogo = SKSpriteNode()                                  //タイトルロゴノード
    var player: SKSpriteNode!                                       //プレイヤーノード
    var back_wall_main: SKSpriteNode!                               //メイン背景
    var back_wall: SKSpriteNode!                                    //メニュー画面背景
    var ground: SKSpriteNode!                                       //地面
    var lowestShape: SKShapeNode!                                   //落下判定シェイプノード
    var attackShape: SKShapeNode!                                   //攻撃判定シェイプノード
    var attackShapeName: String = "attackShape"
    var guardShape: SKShapeNode!                                    //防御判定シェイプノード
    var guardShapeName: String = "guardShape"
    var guardGage = SKSpriteNode()                                     //ガードゲージ
    var start0Node: SKSpriteNode!
    var score = 0                                                   //スコア
    let comboLabel = SKLabelNode()                                  //スコア表示ラベル
    var combo = 0                                                   //スコア
    let highScoreLabel = SKLabelNode()                              //ハイスコア表示ラベル
    var highScore = 0                                               //ハイスコア
    var ultraButton: SKSpriteNode!
    var ultraOkButton: SKSpriteNode!
    var pauseButton: PauseButton!                                   //ポーズボタン
    //MARK: 画面
    var allScreenSize = CGSize(width: 0, height: 0)                 //全画面サイズ
	let oneScreenSize = CGSize(width: 375, height: 667)             //１画面サイズ
    static let ScreenSize = CGSize(width: 375, height: 667) //テスト
    var pauseView: PauseView!                                     //ポーズ画面
    var hudView = HUDView()                                         //HUD
    
    //MARK: タイマー
    var meteorTimer: Timer?                                         //隕石用タイマー
    
    //MARK: フラグ
    var gameoverFlg : Bool = false                                  //ゲームオーバーフラグ
    var attackFlg : Bool = false                                    //攻撃フラグ
    enum guardState{    //ガード状態
        case enable     //ガード可
        case disable    //ガード不可
        case guarding   //ガード中
    }
    var guardStatus = guardState.enable                             //ガード状態
    var moving: Bool = false                                        //移動中フラグ
    var jumping: Bool = false                                       //ジャンプ中フラグ
    var centerPosFlg: Bool = true                                   //中央位置フラグ
    var leftPosFlg: Bool = false                                    //左位置フラグ
    var rightPosFlg: Bool = false                                   //右位置フラグ
    var firstBuildFlg: Bool = true
    var buildFlg:Bool = true
    var gameFlg:Bool = false
    var meteorCollisionFlg = false
    var retryFlg = false                                            //リトライするときにそのままゲームスタートさせる
    enum UAState{ //必殺技の状態
        case none       //未発動
        case landing    //最初の着地
        case attacking  //攻撃中
    }
    var ultraAttackState = UAState.none                             //必殺技発動中フラグ
    
    //MARK: - プロパティ
	//MARK: プレイヤーキャラプロパティ
	var playerAcceleration: CGFloat = 50.0                          //移動加速値
	var playerMaxVelocity: CGFloat = 300.0                          //MAX移動値
	var jumpForce: CGFloat = 60.0                                   //ジャンプ力
    var guardForce: CGFloat = -10.0                                 //ガード反発力
	var charXOffset: CGFloat = 0                                    //X位置のオフセット
	var charYOffset: CGFloat = 0                                    //Y位置のオフセット
    var guardPower : CGFloat = 4500.0                               //ガード可否判定用
    var UltraPower : Int = 0                                        //必殺技可否判定用
    
    //MARK: ポジションプロパティ
    let centerPosition = CGPoint(x: 187.5, y: 243.733)              //中央位置
    let leftPosition = CGPoint(x: 93.75, y: 243.733)                //左位置
    let rightPosition = CGPoint(x: 281.25, y: 243.733)              //右位置
    var defaultYPosition : CGFloat = 0.0
    
    //MARK: 隕石・プレイヤー動作プロパティ
    var playerSpeed : CGFloat = 0.0                                 //プレイヤーの速度
    var meteorSpeed : CGFloat = 0.0                                 //隕石のスピード[pixels/s]
    var meteorUpScale : CGFloat = 0.8                               //隕石の増加倍率
    //調整用パラメータ
    var gravity : CGFloat = -900                                    //重力 9.8 [m/s^2] * 150 [pixels/m]
    var meteorPos :CGFloat = 1320.0                                 //隕石の初期位置(1500.0)
    var meteorGravityCoefficient: CGFloat = 0.04                    //隕石が受ける重力の影響を調整する係数
    var pleyerJumpSpeed : CGFloat = 9.8 * 150 * 1.2                 //プレイヤーのジャンプ時の初速
    var playerUltraAttackSpped : CGFloat = 9.8 * 150 * 2            //プレイヤーの必殺技ジャンプ時の初速
    var playerGravityCoefficient: CGFloat = 1                       //プレイヤーが受ける重力の影響を調整する係数
    var meteorSpeedAtGuard: CGFloat = 100                           //隕石が防御された時の速度
    var speedFromMeteorAtGuard : CGFloat = 350                      //隕石を防御した時にプレイヤーが受ける隕石の速度
    var cameraMax : CGFloat = 1450                                  //カメラの上限
    //MARK: タッチ関係プロパティ
    var beganPos: CGPoint = CGPoint.zero
    var beganPosOnView: CGPoint = CGPoint.zero  //viewの座標系でのタッチ位置
	var tapPoint: CGPoint = CGPoint.zero
    var beganPyPos: CGFloat = 0.0
    var endPyPos:CGFloat = 0.0
    var movePyPos:CGFloat = 0.0
    var touchNode: SKSpriteNode!
    enum TouchAction {  //タッチアクション
        case tap        //タップ
        case swipeUp    //上スワイプ
        case swipeDown  //下スワイプ
        case swipeLeft  //左スワイプ
        case swipeRight //右スワイプ
    }
    
    //MARK: 画面移動プロパティ
	var screenSpeed: CGFloat = 28.0
	var screenSpeedScale: CGFloat = 1.0
    
    var pCamera: SKCameraNode?
    
    //MARK: BGM
    var audioPlayer: AVAudioPlayer!
    
    //MARK: データ保存
    var keyHighScore = "highScore"
    
    //MARK: - 関数定義 シーン関係
	//MARK: シーンが表示されたときに呼ばれる関数
	override func didMove(to view: SKView)
    {
        //MARK: カメラ
        let camera = SKCameraNode()
        self.addChild(camera)
        self.camera = camera
        print("camera : \(self.camera!.position)")
        
        //MARK: 設定関係
        self.backgroundColor = SKColor.clear                           //背景色
        self.physicsWorld.contactDelegate = self                       //接触デリゲート
        self.physicsWorld.gravity = CGVector(dx:0, dy:0)               //重力設定
        
		//MARK: 背景
        self.addChild(self.baseNode)                                //ベース追加
        self.baseNode.addChild(self.playerBaseNode)                 //プレイヤーベース追加
        self.addChild(self.backScrNode)                             //背景追加
 
        //MARK: ゲーム進行関係
        self.meteorTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.fallMeteor), userInfo: nil, repeats: true)                                          //タイマー生成
        
        //MARK: 音楽
        let soundFilePath: String = Bundle.main.path(forResource: "shining_star", ofType: "mp3")!
        let fileURL: URL = URL(fileURLWithPath: soundFilePath)
        try! audioPlayer = AVAudioPlayer(contentsOf: fileURL)
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay()

		//MARK: SKSファイルを読み込み
		if let scene = SKScene(fileNamed: "GameScene.sks")
        {
            //===================
			//MARK: メニュー背景
			//===================
			scene.enumerateChildNodes(withName: "back_wall", using:
            { (node, stop) -> Void in
				let back_wall = node as! SKSpriteNode
				back_wall.name = "backGround"
				//シーンから削除して再配置
				back_wall.removeFromParent()
				self.backScrNode.addChild(back_wall)
                //print("---SKSファイルより背景＝\(back_wall)を読み込みました---")
			})
            //===================
            //MARK: メイン背景
            //===================
            scene.enumerateChildNodes(withName: "back_wall_main", using:
                { (node, stop) -> Void in
                    let back_wall_main = node as! SKSpriteNode
                    back_wall_main.name = "back_wall_main"
                    //シーンから削除して再配置
                    back_wall_main.removeFromParent()
                    self.backScrNode.addChild(back_wall_main)
                    //print("---SKSファイルより背景＝\(back_wall)を読み込みました---")
            })
			//===================
			//MARK: 地面
			//===================
			scene.enumerateChildNodes(withName: "ground", using: { (node, stop) -> Void in
				let ground = node as! SKSpriteNode
				ground.name = "ground"
                ground.physicsBody?.categoryBitMask = 0b0001                //接触判定用マスク設定
                ground.physicsBody?.collisionBitMask = 0b0000 | 0b0000      //接触対象をplayer|meteorに設定
                ground.physicsBody?.contactTestBitMask = 0b0100             //接触対象をplayer|meteorに設定
				//シーンから削除して再配置
				ground.removeFromParent()
				self.baseNode.addChild(ground)
                self.ground = ground
                //print("---SKSファイルより地面＝\(ground)を読み込みました---")
			})
            //===================
            //MARK: 落下判定シェイプノード
            //===================
            scene.enumerateChildNodes(withName: "lowestShape", using: { (node, stop) -> Void in
                let lowestShape = node as! SKShapeNode
                lowestShape.name = "lowestShape"
                let physicsBody = SKPhysicsBody(rectangleOf: lowestShape.frame.size)
                lowestShape.physicsBody = physicsBody
                lowestShape.physicsBody?.affectedByGravity = false      //重力判定を無視
                lowestShape.physicsBody?.isDynamic = false              //固定物に設定
                lowestShape.physicsBody?.categoryBitMask = 0b0010       //接触判定用マスク設定
                lowestShape.physicsBody?.collisionBitMask = 0b0000      //接触対象をなしに設定
                lowestShape.physicsBody?.contactTestBitMask = 0b1000    //接触対象をmeteorに設定
                //シーンから削除して再配置
                lowestShape.removeFromParent()
                self.baseNode.addChild(lowestShape)
                self.lowestShape = lowestShape
                //print("---SKSファイルより落下判定シェイプノード＝\(lowestShape)を読み込みました---")
            })
            //===================
			//MARK: プレイヤー
			//===================
            self.charXOffset = self.oneScreenSize.width * 0.5
			self.charYOffset = self.oneScreenSize.height * 0.5
			scene.enumerateChildNodes(withName: "player", using: { (node, stop) -> Void in
				let player = node as! SKSpriteNode
                player.name = "player"
                //player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64), center: CGPoint(x: 0, y: 0))
                let texture = SKTexture(imageNamed: "player00")
                player.physicsBody = SKPhysicsBody(texture: texture, size: player.size)
                player.physicsBody!.friction = 1.0                      //摩擦
                player.physicsBody!.allowsRotation = false              //回転禁止
                player.physicsBody!.restitution = 0.0                   //跳ね返り値
                player.physicsBody!.mass = 0.03                         //質量
                player.physicsBody?.categoryBitMask = 0b0100            //接触判定用マスク設定
                player.physicsBody?.collisionBitMask = 0b0001           //接触対象を地面に設定
                player.physicsBody?.contactTestBitMask = 0b1000 | 0b0001//接触対象を地面｜meteorに設定
                //シーンから削除して再配置
				player.removeFromParent()
                player.isPaused = false
                self.playerBaseNode.position = player.position   //プレイヤーのポジションをBaseの位置にして
                self.defaultYPosition = player.position.y
                player.position = CGPoint(x:0,y:0)              //baseNodeに追加するplayerの位置は０にする
                print("playerDefault : \(self.defaultYPosition)")
				self.playerBaseNode.addChild(player)
                self.player = player
                //print("---SKSファイルよりプレイヤー＝\(player)を読み込みました---")
                //アニメーション
                let names = ["stand01","stand02"]
                self.startStandTextureAnimation(player, names: names)
            })
            if( debug ){ //デバッグ用
                //addBodyFrame(node: player)  //枠表示
            }
            //===================
            //MARK: タイトルロゴ
            //===================
            scene.enumerateChildNodes(withName: "titleLogo", using:
                { (node, stop) -> Void in
                    let titleLogo = node as! SKSpriteNode
                    titleLogo.name = "titleLogo"
                    //シーンから削除して再配置
                    titleLogo.removeFromParent()
                    self.baseNode.addChild(titleLogo)
                    //print("---SKSファイルより背景＝\(titleLogo)を読み込みました---")
            })
            //===================
            //MARK: コンボ
            //===================
            self.comboLabel.text = String( self.combo )         //スコアを表示する
            self.comboLabel.position = CGPoint(                 //表示位置をplayerのサイズ分右上に
                x: self.player.size.width/2,
                y: self.player.size.height/2 - 50
            )
            self.playerBaseNode.addChild(self.comboLabel)               //playerにaddchiledすることでplayerに追従させる
            //===================
            //MARK: 必殺技ボタン
            //===================
            ultraButton = SKSpriteNode(imageNamed: "ultraButtun")
            self.ultraButton.position = CGPoint(                          //表示位置をplayerのサイズ分左に
                x: 0,
                y: +self.player.size.height / 2
            )
            self.ultraButton.xScale = 1 / 18
            self.ultraButton.yScale = 1 / 18
            self.ultraButton.zPosition = 2
            self.playerBaseNode.addChild(self.ultraButton)               //playerにaddchiledすることでplayerに追従
            ultraOkButton = SKSpriteNode(imageNamed: "ultraOkButtun")
            self.ultraOkButton.position = CGPoint(                       //表示位置をplayerのサイズ分左上に
                x: 0,
                y: +self.player.size.height / 2
            )
            self.ultraOkButton.xScale = 1 / 18
            self.ultraOkButton.yScale = 1 / 18
            self.ultraOkButton.zPosition = 2
            ultraOkButton.removeFromParent()
            self.playerBaseNode.addChild(self.ultraOkButton)             //playerにaddchiledすることでplayerに追従させる
            self.ultraOkButton.isHidden = true
            
            //===================
			//MARK: 壁あたり
			//===================
			let wallFrameNode = SKNode()
			self.baseNode.addChild(wallFrameNode)
			//読み込んだシーンのサイズから外周のあたりを作成する
			wallFrameNode.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: scene.size.width, height: scene.size.height))
			wallFrameNode.physicsBody!.categoryBitMask = 0b0000             //接触判定用マスク設定
			wallFrameNode.physicsBody!.usesPreciseCollisionDetection = true //詳細物理判定

            //===================
            //MARK: start0Node
            //===================
            start0Node = SKSpriteNode(imageNamed: "ロゴ　312　スタート入り")
            self.start0Node.position = CGPoint(                          //表示位置をplayerのサイズ分左に
                x: 189.836,
                y: 1003.673
            )
            //self.ultraButton.xScale = 1 / 18
            //self.ultraButton.yScale = 1 / 18
            self.ultraButton.zPosition = 10
            self.baseNode.addChild(self.start0Node)               //playerにaddchiledすることでplayerに追従
            /*
            scene.enumerateChildNodes(withName: "start0Node", using:
            { (node, stop) -> Void in
                let start0Node = node as! SKSpriteNode
                start0Node.name = "start0Node"
                //シーンから削除して再配置
                start0Node.removeFromParent()
                self.start0Node = start0Node
                self.baseNode.addChild(start0Node)
            })*/
		}
        //攻撃判定用シェイプ
        attackShapeMake()
        //ガード判定用シェイプ
        guardShapeMake()
        //===================
        //MARK: ガードゲージ
        //===================
        guardGage = SKSpriteNode(imageNamed: "pod9")
        guardGage.name = "guardGage"
        guardGage.position = CGPoint(x: player.position.x - 30, y: player.position.y )
        guardGage.zPosition = -1
        guardGage.xScale = 1 / 5
        guardGage.yScale = 1 / 5
        self.playerBaseNode.addChild(self.guardGage)               //playerにaddchiledすることでplayerに追従させる
        
        //ハイスコアラベル
        if ( UserDefaults.standard.object(forKey: keyHighScore) != nil )
        {
            self.highScore = UserDefaults.standard.integer(forKey: self.keyHighScore) //保存したデータの読み出し
            print("read data\(keyHighScore) : \(self.highScore)")
        }
        self.highScoreLabel.text = String( self.highScore ) //ハイスコアを表示する
        self.highScoreLabel.position = CGPoint(             //表示位置は適当
            x: 280.0,
            y: 85.0
        )
        self.highScoreLabel.zPosition = -1                  //プレイヤーの後ろ
        self.baseNode.addChild(self.highScoreLabel)         //背景に固定のつもりでbaseNodeに追加
        //===================
        //MARK: HUD
        //===================
        self.hudView = HUDView(frame: self.frame)
        self.view!.addSubview(hudView)
        self.hudView.drawScore(score: self.score)
        //===================
        //MARK: ポーズ画面
        //===================
        pauseView = PauseView(frame: self.frame)
        pauseView.isHidden = true
        self.view!.addSubview(pauseView)
        //　ポーズボタン
        pauseButton = PauseButton()
        pauseButton.layer.anchorPoint = CGPoint(x: 1, y: 0)//右上
        pauseButton.layer.position = CGPoint(x: frame.maxX - 10, y: 25)
        pauseButton.setPauseFunc{
            self.sliderHidden = !self.sliderHidden
            self.pauseView.isHidden = self.sliderHidden
            self.view!.scene?.isPaused = !self.sliderHidden
            self.pause()
        }
        pauseButton.setResumeFunc{
            self.sliderHidden = !self.sliderHidden
            self.pauseView.isHidden = self.sliderHidden
            self.view!.scene?.isPaused = !self.sliderHidden
            self.play()
        }
        pauseButton.isHidden = true     //タイトル画面では非表示
        self.view!.addSubview(pauseButton)
        
        // アプリがバックグラウンドから復帰した際に呼ぶ関数の登録
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(becomeActive(_:)),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        if(debug)
        {
            addParamSlider()                                //パラメータ調整用スライダー
            view.showsPhysics = true
            let playerBaseShape = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 10, height: 10))
            playerBaseShape.zPosition = -50
            playerBaseNode.addChild( playerBaseShape )
        }
        setDefaultParam()
        if( retryFlg )
        { //リトライ時はそのままスタートする
            startButtonAction()
        }
        scaleLoopAction(start0Node)
	}
    
    //アプリがバックグラウンドから復帰した際に呼ばれる関数
    //起動時にも呼ばれる
    @objc func becomeActive(_ notification: Notification) {
        if( gameFlg == false )
        {
            //ゲームが始まっていなければなにもしない
            return
        }
        isPaused = true     //ポーズ状態にする
        if( sliderHidden == true ){ //ポーズボタンが押されていなかった
            if( gameoverFlg == false ){ //ゲームオーバになっていない時
                pauseButton.pauseAction()
            }
        }
    }
    
    //MARK: シーンのアップデート時に呼ばれる関数
    override func update(_ currentTime: TimeInterval)
    {
        if ( !meteores.isEmpty )
        {
            self.meteorSpeed += self.gravity * meteorGravityCoefficient / 60
            for m in meteores
            {
                m.position.y += self.meteorSpeed / 60
            }
        }
        if jumping == true
        {
            // 次の位置を計算する
            self.playerSpeed += self.gravity * self.playerGravityCoefficient / 60   // [pixcel/s^2] / 60[fps]
            self.playerBaseNode.position.y += CGFloat( playerSpeed / 60 )           // [pixcel/s] / 60[fps]
            if ( !meteores.isEmpty ){
                let meteor = self.meteores.first
                let meteorMinY = (meteor?.position.y)! - ((meteor?.size.height)!/2)
                let playerMaxY = playerBaseNode.position.y + ((player?.size.height)!/2)
                let playerHalfSize: CGFloat = 20 // playerPhisicsBody / 2 の実測値
                if( meteorCollisionFlg ){ //衝突する
                    self.playerBaseNode.position.y = meteorMinY - playerHalfSize
                    self.playerSpeed -= self.meteorSpeed / 60
                    if( self.playerSpeed < self.meteorSpeed ){
                        //playerが上昇中にfalseにすると何度も衝突がおきてplayeerがぶれるので
                        //落下速度が隕石より早くなってからfalseにする
                        self.meteorCollisionFlg = false
                    }
                    if( debug )
                    {
                        //衝突位置表示
                        var points = [CGPoint(x:frame.minX,y:playerBaseNode.position.y + playerHalfSize),
                                      CGPoint(x:frame.maxX,y:playerBaseNode.position.y + playerHalfSize)]
                        if( collisionLine != nil )
                        {
                            collisionLine.removeFromParent()
                        }
                        collisionLine = SKShapeNode(points: &points, count: points.count)
                        collisionLine.strokeColor = UIColor.clear
                        baseNode.addChild(collisionLine)
                    }
                }
                else
                {
                    if ( debug )
                    {
                        if( collisionLine != nil )
                        {
                            collisionLine.removeFromParent()
                            collisionLine = nil
                        }
                    }
                }
            }
            if( self.playerBaseNode.position.y < defaultYPosition )
            {
                self.playerBaseNode.position.y = defaultYPosition
            }
            player.position = CGPoint.zero //playerの位置がだんだん上に上がる対策
        }
        else{
            if( !meteores.isEmpty ){
                let meteor = self.meteores.first
                let meteorMinY = (meteor?.position.y)! - ((meteor?.size.height)!/2)
                let playerHalfSize = (player?.size.height)!/2
                if( self.playerBaseNode.position.y < meteorMinY - playerHalfSize ){
                    meteorCollisionFlg = false
                    if( collisionLine != nil ){
                        collisionLine.removeFromParent()
                        collisionLine = nil
                    }
                }
            }
            else{
                meteorCollisionFlg = false
                if( collisionLine != nil ){
                    collisionLine.removeFromParent()
                    collisionLine = nil
                }
            }
        }
        
        if (gameFlg == false)
        {
            self.camera!.position = CGPoint(x: self.oneScreenSize.width/2,y: self.start0Node.position.y)
        }
        else if (jumping == true) && (self.playerBaseNode.position.y + 200 > self.oneScreenSize.height/2)
        {
            if( self.playerBaseNode.position.y < self.cameraMax ) //カメラの上限を超えない範囲で動かす
            {
                self.camera!.position = CGPoint(x: self.oneScreenSize.width/2,y: self.playerBaseNode.position.y + 200 );
            }
        }
        else
        {
            self.camera!.position = CGPoint(x: self.oneScreenSize.width/2,y: self.oneScreenSize.height/2)
        }
        if( debug )
        {
            playerPosLabel.text = "playerSpeed : \(self.playerSpeed) \n" + "y +: \(CGFloat( playerSpeed / 60 ))"
        }
        if guardPower < 0
        {
            guardPower = 0
        }
        else if guardPower <= 4500
        {
            guardPower += 10
            if( ( guardPower >= 4500 ) && ( guardStatus == .disable ) ){
                guardStatus = .enable
            }
        }
        //guardGage.yScale = CGFloat(guardPower / 1000)
        
    }
    //MARK: すべてのアクションと物理シミュレーション処理後、1フレーム毎に呼び出される
    override func didSimulatePhysics()
    {   }
    //MARK: - 関数定義　タッチ処理
    //MARK: タッチダウンされたときに呼ばれる関数
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard ( ultraAttackState == .none ) else { //必殺技中でなければ次の処理に進む
            return
        }
        guard ( gameoverFlg == false ) else {  //ゲームオーバでなければ次の処理に進む
            return
        }
        //ポーズでなければ次の処理に進む
        guard ( self.view!.scene?.isPaused == false ) else {
            return
        }
        
        if let touch = touches.first as UITouch?
        {
            self.beganPosOnView = CGPoint(x: touch.location(in: view).x,
                                          y: frame.maxY - touch.location(in: view).y ) //y座標を反転する
            self.beganPos = touch.location(in: self)
            self.beganPyPos = (camera?.position.y)!                     //カメラの移動量を計算するために覚えておく
            if( touchPath != nil ){ //すでにタッチの軌跡が描かれていれば削除
                touchPath.removeFromParent()
            }
            //タッチしたノードを記録しておく
            //print("---タップをしたノード=\(String(describing: touchNode?.name))---")
            touchNode = self.atPoint(beganPos) as? SKSpriteNode
        }
    }

    //MARK: タッチ移動されたときに呼ばれる関数
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard ( ultraAttackState == .none ) else { //必殺技中でなければ次の処理に進む
            return
        }
        guard ( gameoverFlg == false ) else {  //ゲームオーバでなければ次の処理に進む
            return
        }
        //ポーズでなければ次の処理に進む
        guard ( self.view!.scene?.isPaused == false ) else {
            return
        }
        
        for touch: AnyObject in touches
        {
            let endPosOnView = CGPoint(x: touch.location(in: view).x,
                                       y: frame.maxY - touch.location(in: view).y )
            drawTouchPath(begin: beganPosOnView, end: endPosOnView)
            switch getTouchAction(begin: beganPosOnView, end: endPosOnView) {
            case .tap:
                break   //何もしない
            case .swipeDown:
                guardAction(endFlg: false)
            case .swipeUp: //ジャンプしてない場合のみ
                break   //何もしない
            case .swipeLeft: //ジャンプしてない場合のみ
                break   //何もしない
            case .swipeRight://ジャンプしてない場合のみ
                break   //何もしない
            }
            /*
            let endedPos = touch.location(in: self)                          //タップを話した点を定義
            let cameraMoveY = ( (camera?.position.y)! -  self.beganPyPos )   //前回からのカメラの移動量を求める
            self.beganPyPos = (camera?.position.y)!                          //次回計算時のために現在位置を覚える
            self.beganPos.y += cameraMoveY                                   //カメラが動いた分だけタッチ開始点も動かす
            let xPos = beganPos.x - endedPos.x
            let yPos = beganPos.y - endedPos.y
            if( touchPath != nil )                                           //すでにタッチの軌跡が描かれていれば削除
            {
                touchPath.removeFromParent()
            }
            var points = [beganPos,endedPos]
            touchPath = SKShapeNode(points: &points, count: points.count)   //デバッグ用に始点から現在地を線で結ぶ
            if fabs(yPos) > fabs(xPos)
            {
                if yPos > 0                                                 //下スワイプ
                {
                    guardPower -= 100
                    guardAction(endFlg: false)
                    touchPath.strokeColor = UIColor.blue
                }
                else if yPos < 0                                           //上スワイプ
                {
                    touchPath.strokeColor = UIColor.white
                }
            }
            else
            {
                if xPos > 100                                             //左スワイプ
                {
                    touchPath.strokeColor = UIColor.white
                }
                else if xPos < -100                                       //右スワイプ
                {
                    touchPath.strokeColor = UIColor.white
                }
            }
            if( debug )
            {
                baseNode.addChild(touchPath)
            }
            */
         }
    }
    
    //MARK: タッチアップされたときに呼ばれる関数
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard ( ultraAttackState == .none ) else { //必殺技中でなければ次の処理に進む
            return
        }
        guard ( gameoverFlg == false ) else {  //ゲームオーバでなければ次の処理に進む
            return
        }
        //ポーズでなければ次の処理に進む
        guard ( self.view!.scene?.isPaused == false ) else {
            return
        }
        
        for touch: AnyObject in touches
        {
            let endPosOnView = CGPoint(x: touch.location(in: view).x,
                                       y: frame.maxY - touch.location(in: view).y )
            let endPos = touch.location(in: self)
            //ボタンタップ判定
            let node:SKSpriteNode? = self.atPoint(endPos) as? SKSpriteNode;
            if( node == touchNode ) { // タッチ開始時と同じノードで離した
                //print("---タップを離したノード=\(String(describing: node?.name))---")
                var buttonPushFlg = true
                switch node{ //押したボタン別処理
                case let node where node == start0Node :
                    startButtonAction()
                case let node where node == ultraOkButton :
                    ultraAttack()
                default:
                    buttonPushFlg = false
                }
                // ボタンが押されていればスワイプ処理はしないので抜ける
                if buttonPushFlg == true
                {
                    return
                }
            }
            //スワイプ判定
            drawTouchPath(begin: beganPosOnView, end: endPosOnView)
            switch getTouchAction(begin: beganPosOnView, end: endPosOnView) {
            case .tap:
                attackAction()
            case .swipeDown:
                guardAction(endFlg: true)
            case .swipeUp where jumping == false: //ジャンプしてない場合のみ
                jumpingAction()
            case .swipeLeft where jumping == false: //ジャンプしてない場合のみ
                moveToLeft()
            case .swipeRight where jumping == false://ジャンプしてない場合のみ
                moveToRight()
            default:
                break   //何もしない
            }
        }
    }
    func getTouchAction(begin: CGPoint, end:CGPoint) ->TouchAction
    {
        let moveX = end.x - begin.x
        let moveY = end.y - begin.y
        let margin:CGFloat = 50
        //移動量が少なかったらタップ
        if( fabs(moveX) < margin && fabs(moveY) < margin ){
            return TouchAction.tap
        }
        // 絶対値が大きいほうの動作を優先、値の正負で方向を判定する
        switch( moveX,moveY ){
        case (let x, let y) where fabs(x) > fabs(y) && x > 0:
            return TouchAction.swipeRight
        case (let x, let y) where fabs(x) > fabs(y) && x < 0:
            return TouchAction.swipeLeft
        case (let x, let y) where fabs(x) <= fabs(y) && y > 0:
            return TouchAction.swipeUp
        case (let x, let y) where fabs(x) <= fabs(y) && y < 0:
            return TouchAction.swipeDown
        default:
            break
        }
        //ここは通らないはず
        print("ありえないTouchAction x:\(moveX),y:\(moveY)")
        return TouchAction.tap
    }
    var touchPath: SKShapeNode! = nil
    func drawTouchPath(begin: CGPoint, end:CGPoint){
        //カメラが存在するかどうかのチェック
        guard let camera = camera else{
            return
        }
        //すでにタッチの軌跡が描かれていれば削除
        if( touchPath != nil ){
            touchPath.removeFromParent()
        }
        //カメラの移動分平行移動する
        let moveX = camera.position.x - oneScreenSize.width / 2
        let moveY = camera.position.y - oneScreenSize.height / 2
        var points = [ CGPoint( x: begin.x + moveX, y: begin.y + moveY ),
                       CGPoint( x: end.x + moveX, y: end.y + moveY ) ]
        //線の作成
        touchPath = SKShapeNode(points: &points, count: points.count)
        //色の設定
        switch getTouchAction(begin: begin, end: end){
        case .tap:
            touchPath.strokeColor = UIColor.red
        case .swipeUp:
            touchPath.strokeColor = UIColor.green
        case .swipeDown:
            touchPath.strokeColor = UIColor.blue
        case .swipeLeft:
            touchPath.strokeColor = UIColor.yellow
        case .swipeRight:
            touchPath.strokeColor = UIColor.yellow
        }
        //線の描画
        baseNode.addChild(touchPath)
    }
    
    //MARK: - 移動
    let moveL = SKAction.moveTo(x: 93.75, duration: 0.15)
    let moveC = SKAction.moveTo(x: 187.5, duration: 0.15)
    let moveR = SKAction.moveTo(x: 281.25, duration: 0.15)
    //MARK: - 右移動
    func moveCtoR()
    {
        if jumping == false
        {
            self.centerPosFlg = false
            self.leftPosFlg = false
            self.rightPosFlg = true
            self.moving = true
            let names = ["attack01","attack02","player00"]
            self.attackTextureAnimation(self.player, names: names)
            playerBaseNode.run(moveR)
            playSound(soundName: "move")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                self.moveStop()
            }
        }
    }
    func moveLtoC()
    {
        if jumping == false
        {
            self.centerPosFlg = true
            self.leftPosFlg = false
            self.rightPosFlg = false
            self.moving = true
            let names = ["attack01","attack02","player00"]
            attackTextureAnimation(self.player, names: names)
            playerBaseNode.run(moveC)
            playSound(soundName: "move")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                self.moveStop()
            }
        }
    }
    func moveToRight()
    {
        if centerPosFlg == true
        {
            moveCtoR()
        }
        else if leftPosFlg == true
        {
            moveLtoC()
        }
    }
    //MARK: - 左移動
    func moveCtoL()
    {
        if jumping == false
        {
            self.centerPosFlg = false
            self.leftPosFlg = true
            self.rightPosFlg = false
            let names = ["attack01","attack02","player00"]
            attackTextureAnimation(self.player, names: names)
            playerBaseNode.run(moveL)
            playSound(soundName: "move")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                self.moveStop()
            }
        }
    }
    func moveRtoC()
    {
        if jumping == false
        {
            self.centerPosFlg = true
            self.leftPosFlg = false
            self.rightPosFlg = false
            let names = ["attack01","attack02","player00"]
            attackTextureAnimation(self.player, names: names)
            playerBaseNode.run(moveC)
            playSound(soundName: "move")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                self.moveStop()
            }
        }
    }
    func moveToLeft()
    {
        if centerPosFlg == true
        {
            moveCtoL()
        }
        else if rightPosFlg == true
        {
            moveRtoC()
        }
    }
    
    //MARK: - 停止
    func moveStop() {
        moving = false
        if jumping == false {
            self.player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        }
        let names = ["stand01","stand02"]
        self.startStandTextureAnimation(player, names: names)
    }
    
    //MARK: - ジャンプ
    func jumpingAction() {
        if jumping == false {
            moving = false
            jumping = true
            playerSpeed = pleyerJumpSpeed
            playSound(soundName: "jump")
        }
    }
    
    //MARK: - 関数定義　接触判定
    func didBegin(_ contact: SKPhysicsContact) {
        //print("---didBeginで衝突しました---")
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        let nameA = nodeA?.name
        let nameB = nodeB?.name
        let bitA = contact.bodyA.categoryBitMask
        let bitB = contact.bodyB.categoryBitMask
        //print("---接触したノードは\(String(describing: nameA))と\(String(describing: nameB))です---")
        
        if (bitA == 0b10000 || bitB == 0b10000) && (bitA == 0b1000 || bitB == 0b1000)
        {
            //print("---MeteorとattackShapeが接触しました---")
            attackMeteor()
        }
        else if (bitA == 0b100000 || bitB == 0b100000) && (bitA == 0b1000 || bitB == 0b1000)
        {
            //print("---MeteorとguardShapeが接触しました---")
            guardMeteor()
        }
        else if (bitA == 0b0010 || bitB == 0b0010) && (bitA == 0b1000 || bitB == 0b1000)
        {
            //print("---MeteorとGameOverが接触しました---")
            if( ultraAttackState == .none ){ //必殺技中はゲームオーバーにしない
                gameOver()
            }
        }
        else if (bitA == 0b0100 || bitB == 0b0100) && (bitA == 0b0001 || bitB == 0b0001)
        {
            //print("---Playerと地面が接触しました---")
            jumping = false
            playSound(soundName: "tyakuti")
            self.playerSpeed = 0.0
            self.playerBaseNode.position.y = self.defaultYPosition
            switch ( ultraAttackState )
            {
            case .landing:
                ultraAttackState = .attacking
                ultraAttackJump()
                break
            case .attacking:
                ultraAttackEnd()
                break
            case .none:
                //何もしない
                break
            }
        }
        else if (bitA == 0b0100 || bitB == 0b0100) && (bitA == 0b1000 || bitB == 0b1000)
        {
            //print("---Playerとmeteorが接触しました---")
            meteorCollisionFlg = true;
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        //print("------------didEndで衝突しました------------")
        //print("bodyA:\(contact.bodyA)")
        //print("bodyB:\(contact.bodyB)")
        return
    }
    
    //MARK: - 関数定義　自分で設定関係
    
    //MARK: 配列
    var meteorNames: [String] = ["normal_meteor"]
    var meteorInt: Int = 0
    var meteorDouble: Double = 70.0
    var meteores: [SKSpriteNode] = []
    
    //MARK: 隕石落下
    func buildMeteor(size: Double, meteorString: String, meteorZ: Double){
        self.firstBuildFlg = false
        self.buildFlg = false
        let texture = SKTexture(imageNamed: meteorString)
        let meteor = SKSpriteNode(texture: texture)
        meteor.zPosition = CGFloat(meteorZ)
        meteor.size = CGSize(width: texture.size().width, height: texture.size().height)
        meteor.xScale = CGFloat(size)
        meteor.yScale = CGFloat(size)
        if meteores.isEmpty
        {
            //meteor.position = CGPoint(x: 187, y: self.meteorPos + (meteor.size.height)/2)
            meteor.position = CGPoint(x:187, y: self.playerBaseNode.position.y + 700 + (meteor.size.height) / 2)
        } else
        {
            meteor.position = CGPoint(x: 187, y: (meteores.first?.position.y)!)
        }
        meteor.physicsBody = SKPhysicsBody(texture: texture, size: meteor.size)
        meteor.physicsBody?.affectedByGravity = false
        meteor.physicsBody?.categoryBitMask = 0b1000                         //接触判定用マスク設定
        meteor.physicsBody?.collisionBitMask = 0b0000                        //接触対象をなしに設定
        meteor.physicsBody?.contactTestBitMask = 0b0010 | 0b10000 | 0b100000 | 0b0100 //接触対象を各Shapeとプレイヤーに設定
        meteor.name = "meteor"//meteorString
        self.addChild(meteor)
        //print("---meteor\(meteorString)を生成しました---")
        self.meteores.append(meteor)
        if( debug ){    //デバッグ用
            //addBodyFrame(node: meteor)  //枠を表示
        }
    }
    func startButtonAction()
    {
        play()
        start0Node.zPosition = -50
        if( retryFlg == false ){
            //リトライ時はカメラ動かさない
            let action1 = SKAction.moveTo(y: self.player.position.y + 300, duration: 1)
            let action2 = SKAction.run {
                self.gameFlg = true
            }
            let actionAll = SKAction.sequence([action1,action2])
            camera?.run(actionAll)
        }
        else{
            gameFlg = true
        }
        pauseButton.isHidden = false //ポーズボタンを表示する
        /*
        //メニュー背景を動かすアクションを作成する。
        let action1 = SKAction.moveTo(y: -3000, duration: 1.0)
        //アクションを実行する。
        back_wall.run(action1)
         */
        //playBgm(soundName: "bgmn")
    }
    
    @objc func fallMeteor()
    {
        if gameFlg == false
        {
            return
        }
        else if firstBuildFlg == true
        {
            buildMeteor(size: 0.3, meteorString: "meteor_meteor_20180128", meteorZ: 20.0)
        }
        else if buildFlg == false
        {
            return
        }
        else if buildFlg == true
        {
            meteorInt += 1
            meteorDouble = 20.0
            self.meteorSpeed = 0.0
            self.meteorGravityCoefficient = CGFloat(0.05 + 0.01 * Double(meteorInt))
            //print("--meteorGravityCoeffient\(meteorGravityCoefficient)--")
            for i in (0...meteorInt).reversed()
            {
                meteorDouble -= 1.0
                buildMeteor(size: Double(0.3 + (CGFloat(i) * meteorUpScale)),meteorString: meteorNames[0], meteorZ: meteorDouble)
                    //print("---meteorInt = \(i)です-----")
            }
        }
        else
        {
            return
        }
    }
    
    //MARK: 攻撃
    func attackShapeMake()
    {
        let attackShape = SKShapeNode(rect: CGRect(x: 0.0 - self.player.size.width/2, y: 0.0 - self.player.size.height/2, width: self.player.size.width, height: self.player.size.height))
        attackShape.name = attackShapeName
        let physicsBody = SKPhysicsBody(rectangleOf: attackShape.frame.size)
        attackShape.position = CGPoint(x: 0, y: player.size.height)
        attackShape.fillColor = UIColor.clear
        attackShape.strokeColor = UIColor.clear
        attackShape.zPosition = 1
        attackShape.physicsBody = physicsBody
        attackShape.physicsBody?.affectedByGravity = false      //重力判定を無視
        attackShape.physicsBody?.isDynamic = false              //固定物に設定
        attackShape.physicsBody?.categoryBitMask = 0b10000      //接触判定用マスク設定
        attackShape.physicsBody?.collisionBitMask = 0b0000      //接触対象をなしに設定
        attackShape.physicsBody?.contactTestBitMask = 0b1000    //接触対象をmeteorに設定
        //print("---attackShapeを生成しました---")
        self.attackShape = attackShape
    }
    
    func attackAction()
    {
        if gameoverFlg == true
        {
            return
        }
        if attackFlg == false
        {
            //print("---アタックフラグをON---")
            self.attackFlg = true
            let names = ["attack01","attack02","player00"]
            self.attackTextureAnimation(self.player, names: names)
            playSound(soundName: "slash")
            if playerBaseNode.childNode(withName: attackShapeName) == nil {
                self.playerBaseNode.addChild(attackShape)
                let action1 = SKAction.wait(forDuration: 0.3)
                let action2 = SKAction.removeFromParent()
                let action3 = SKAction.run{
                    self.attackFlg = false
                    //print("---アタックフラグをOFF---")
                }
                let actions = SKAction.sequence([action1,action2,action3])
                attackShape.run(actions)
            }
        }
    }
    
    func attackMeteor()
    {
        if gameoverFlg == true
        {
            return
        }
        if attackFlg == true
        {
            //print("---隕石を攻撃---")
            if meteores.isEmpty == false
            {
                if ultraAttackState == .none //必殺技のときは続けて攻撃するため
                {
                    if let attackNode = playerBaseNode.childNode(withName: attackShapeName)
                    {
                        attackNode.removeAllActions()
                        attackNode.removeFromParent()
                    }
                    attackFlg = false
                    //print("---アタックフラグをOFF---")
                }
                meteores[0].physicsBody?.categoryBitMask = 0
                meteores[0].physicsBody?.contactTestBitMask = 0
                meteores[0].removeFromParent()
                //隕石を爆発させる
                let particle = SKEmitterNode(fileNamed: "MeteorBroken.sks")
                //接触座標にパーティクルを放出するようにする。
                particle!.position = CGPoint(x: playerBaseNode.position.x,
                                             y: playerBaseNode.position.y + (attackShape.position.y))
                //0.7秒後にシーンから消すアクションを作成する。
                let action1 = SKAction.wait(forDuration: 0.5)
                let action2 = SKAction.removeFromParent()
                let actionAll = SKAction.sequence([action1, action2])
                //パーティクルをシーンに追加する。
                self.addChild(particle!)
                //アクションを実行する。
                particle!.run(actionAll)
                //print("---消すノードは\(meteores[0])です---")
                meteores.remove(at: 0)
                //print("---UltraPowerは\(UltraPower)です---")
                //self.meteorGravityCoefficient -= 0.06                   //数が減るごとに隕石の速度を遅くする
                //スコア
                self.score += 1;
                self.hudView.drawScore( score: self.score )
                //コンボ
                self.combo += 1;
                self.comboLabel.text = String( self.combo )
                //必殺技
                if( ultraAttackState == .none )
                {
                    UltraPower += 1
                    if UltraPower >= 10
                    {
                        ultraButton.isHidden = true
                        ultraOkButton.isHidden = false
                    }
                }
                playSound(soundName: "hakai")
                vibrate()
                //隕石と接触していたら速度を0にする
                if( meteorCollisionFlg )
                {
                    self.meteorCollisionFlg = false
                    playerSpeed = 0;
                }
            }
            if meteores.isEmpty == true
            {
                if ultraAttackState == .none //必殺技中は着地後に生成する
                {
                    self.buildFlg = true
                    //print("---meteoresが空だったのでビルドフラグON---")
                }
            }
        }
    }
    
    //必殺技
    func ultraAttack(){
        print("!!!!!!!!!!ultraAttack!!!!!!!!!")
        //ボタンを元に戻す
        ultraButton.isHidden = false
        ultraOkButton.isHidden = true
        UltraPower = 0
        //入力を受け付けないようにフラグを立てる
        ultraAttackState = .landing
        if( jumping ) //空中にいる場合
        {
            //地面に戻る
            playerSpeed = -2000
        }
        else
        {
            ultraAttackState = .attacking
            //大ジャンプ
            ultraAttackJump()
        }
        //ultraAttackフラグは地面に着いた時に落とす
    }
    func ultraAttackJump(){
        //攻撃Shapeを出す
        self.attackFlg = true
        if let attackNode = playerBaseNode.childNode(withName: attackShapeName) {
            attackNode.removeAllActions()
            attackNode.removeFromParent()
        }
        else{
            self.playerBaseNode.addChild(attackShape)
        }
        //大ジャンプ
        moving = false
        jumping = true
        playerSpeed = self.playerUltraAttackSpped
        //サウンド
        playSound(soundName: "jump")
    }
    func ultraAttackEnd(){
        self.attackFlg = false
        //attackShapeを消す
        if let attackNode = playerBaseNode.childNode(withName: attackShapeName)
        {
            attackNode.removeFromParent()
        }
        //フラグを落とす
        ultraAttackState = .none
        if( meteores.isEmpty ){ //全て壊せているはずだが一応チェックする
            //次のmeteores生成
            self.buildFlg = true
        }
    }
    //MARK: 防御
    func guardShapeMake()
    {
        let guardShape = SKShapeNode(rect: CGRect(x: 0.0 - self.player.size.width/2, y: 0.0 - self.player.size.height/2, width: self.player.size.width, height: self.player.size.height + 10))
        guardShape.name = "guardShape"
        let physicsBody = SKPhysicsBody(rectangleOf: guardShape.frame.size)
        guardShape.position = CGPoint(x: 0, y: 0)
        guardShape.fillColor = UIColor.clear
        guardShape.strokeColor = UIColor.clear
        guardShape.zPosition = 1
        guardShape.physicsBody = physicsBody
        guardShape.physicsBody?.affectedByGravity = false      //重力判定を無視
        guardShape.physicsBody?.isDynamic = false              //固定物に設定
        guardShape.physicsBody?.categoryBitMask = 0b100000     //接触判定用マスク設定
        guardShape.physicsBody?.collisionBitMask = 0b0000      //接触対象をなしに設定
        guardShape.physicsBody?.contactTestBitMask = 0b1000    //接触対象をmeteorに設定
        self.guardShape = guardShape
        //print("---guardShapeを生成しました---")
    }
    
    func guardAction(endFlg: Bool)
    {
        if gameoverFlg == true
        {
            return
        }
        else if (guardStatus != .disable)
        {
            if( guardStatus != .guarding )
            {   //ガード開始
                //print("---ガードフラグをON---")
                self.guardStatus = .guarding
                print(self.guardStatus)
                playerBaseNode.addChild( guardShape )
            }
            if( endFlg == true )
            {
                if let guardNode = playerBaseNode.childNode(withName: guardShapeName) {
                    let action1 = SKAction.wait(forDuration: 0.1)
                    let action2 = SKAction.removeFromParent()
                    let action3 = SKAction.run{
                        if( self.guardStatus != .disable ){
                            self.guardStatus = .enable
                            //print("---ガードフラグをOFF---")
                        }
                    }
                    let actions = SKAction.sequence([action1,action2,action3])
                    guardNode.run(actions)
                }
                //アニメーション
                let names = ["guard01","player00"]
                self.guardTextureAnimation(self.player, names: names)
            }
            else{
                //アニメーション
                let names = ["guard01"]
                self.guardTextureAnimation(self.player, names: names)
            }
        }
    }

    func guardMeteor()
    {
        if gameoverFlg == true
        {
            return
        }
        if (guardStatus == .guarding)
        {
            //print("---隕石をガード---")
            playSound(soundName: "bougyo")
            guardPower -= 1500
            if( guardPower < 0 ){
                print( "guardBroken!!" )
                guardStatus = .disable
                print(self.guardStatus)
            }
            //ガードシェイプ削除
            if let guardNode = playerBaseNode.childNode(withName: guardShapeName) {
                guardNode.removeFromParent()
            }
            if( guardStatus != .disable ){
                guardStatus = .enable
            }
            for i in meteores
            {
                i.removeAllActions()
                if jumping == true {
                    self.playerSpeed = self.speedFromMeteorAtGuard  //プレイヤーの速度が上がる
                    let meteor = self.meteores.first
                    let meteorMinY = (meteor?.position.y)! - ((meteor?.size.height)!/2)
                    let playerHalfSize = (player?.size.height)!/2
                    self.playerBaseNode.position.y = meteorMinY - playerHalfSize - 1
                }
                self.meteorSpeed = self.meteorSpeedAtGuard       //上に持ちあげる
                //print("---隕石がガードされたモーションを実行---")
                self.combo = 0
                self.comboLabel.text = String( self.combo )
            }
        }
        else
        {
            //print("---guardShapeとmeteorが衝突したけどフラグOFFでした---")
            return
        }
    }
    func gameOver()
    {
        if( !gameoverFlg ){ //既にGameOverの場合はなにもしない
            self.gameoverFlg = true
            self.meteorTimer?.invalidate()
            pauseButton.isHidden = true//ポーズボタンを非表示にする
            //ハイスコア更新
            print("------------score:\(self.score) high:\(self.highScore)------------")
            if( self.score > self.highScore ){
                self.highScore = self.score
                self.highScoreLabel.text = String(self.highScore)
                print("------------hidh score!------------")
                UserDefaults.standard.set(self.highScore, forKey: self.keyHighScore) //データの保存
            }
            print("------------gameover------------")
            stop()
            //墜落演出
            let circle = SKShapeNode(circleOfRadius:1)
            circle.position = playerBaseNode.position
            circle.zPosition = 1500.0
            circle.fillColor = UIColor.white
            self.addChild(circle)
            let actions = SKAction.sequence(
                [ SKAction.scale(to: 1000, duration: 1.0),
                  SKAction.wait(forDuration: 0.5),
                  SKAction.fadeOut(withDuration: 1),
                  SKAction.removeFromParent(),
                  SKAction.run{self.isPaused = true},
                  SKAction.run(gameOverViewCreate)])
            circle.run(actions)
        }
    }
    
    var gameOverView: GameOverView!
    func gameOverViewCreate(){
        
        print("gameOverViewCreate")
        //ゲームオーバー画面
        gameOverView = GameOverView(frame: self.frame, score: self.score, highScore: self.highScore )
        var buttonX:CGFloat = 10    //左端の余白
        var buttonY = gameOverView.frame.size.height - 10    //下端の余白
        //Titleボタン
        let newGameBtn = IconButton(image:"home", color:UIColor(red: 0.1, green: 0.8, blue: 0.6, alpha: 1))
        newGameBtn.layer.position = CGPoint(x: buttonX, y: buttonY )
        newGameBtn.addTarget(self, action: #selector(self.newGameButtonAction), for: .touchUpInside)
        gameOverView.addSubview(newGameBtn)
        buttonX += newGameBtn.frame.size.width + 10
        //Retryボタン
        let retryBtn = IconButton(image: "restart", color: UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1))
        retryBtn.layer.position = CGPoint(x: buttonX, y: buttonY)
        retryBtn.addTarget(self, action: #selector(self.retryButtonAction), for: .touchUpInside)
        gameOverView.addSubview(retryBtn)
        self.view!.addSubview(gameOverView)
    }

    @objc func newGameButtonAction(_ sender: UIButton ){
        removeParamSlider()
        gameOverView.removeFromSuperview()
        newGame()
    }
    @objc func retryButtonAction(_ sender: UIButton ){
        removeParamSlider()
        gameOverView.removeFromSuperview()
        let scene = GameScene(size: self.scene!.size)
        scene.scaleMode = SKSceneScaleMode.aspectFill
        scene.retryFlg = true
        self.view?.presentScene(scene)
    }
    
    func newGame()
    {
        let scene = GameScene(size: self.scene!.size)
        scene.scaleMode = SKSceneScaleMode.aspectFill
        self.view?.presentScene(scene)
    }
    
    //MARK: 音楽
    func playSound(soundName: String)
    {
        let mAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        self.run(mAction)
    }
    
    func playBgm(soundName: String)
    {
        let action = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        let actionLoop = SKAction.repeatForever(action)
        self.run(actionLoop, withKey: "actionLoop")
    }
    
    func play()
    {
        audioPlayer.play()
    }
    
    func pause()
    {
        audioPlayer.pause()
    }
    
    func stop()
    {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
    }
    
    func vibrate() {
        //AudioServicesPlaySystemSound(1519)
        //AudioServicesDisposeSystemSoundID(1519)
    }

    //==========================================================
    //MARK: - テクスチャアニメーション
    //==========================================================
    //開始
    func startTextureAnimation(_ node: SKSpriteNode, names: [String]) {
        node.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in names {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: true, restore: false)
        node.run(SKAction.repeatForever(action), withKey: "textureAnimation")
    }
    
    //停止
    func stopTextureAnimation(_ node: SKSpriteNode, name: String) {
        node.removeAction(forKey: "textureAnimation")
        node.texture = SKTexture(imageNamed: name)
    }
    
    //立ちアニメ
    func startStandTextureAnimation(_ node: SKSpriteNode, names: [String]) {
        node.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in names {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 1.0, resize: false, restore: false)
        node.run(SKAction.repeatForever(action), withKey: "textureAnimation")
    }
    
    func attackTextureAnimation(_ node: SKSpriteNode, names: [String]) {
        node.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in names {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        node.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
 
    func guardTextureAnimation(_ node: SKSpriteNode, names: [String]) {
        node.removeAction(forKey: "textureAnimation")
        var ary: [SKTexture] = []
        for name in names {
            ary.append(SKTexture(imageNamed: name))
        }
        let action = SKAction.animate(with: ary, timePerFrame: 0.1, resize: false, restore: false)
        node.run(SKAction.repeat(action, count:1), withKey: "textureAnimation")
    }
    
    func scaleLoopAction(_ node: SKSpriteNode){
        let actions = SKAction.sequence(
            [ SKAction.scale(to: 1.1, duration: 1.0),
              //SKAction.wait(forDuration: 0.1),
              SKAction.scale(to: 1.0, duration: 1.0),
              //SKAction.wait(forDuration: 0.1),
              SKAction.scale(to: 0.9, duration: 1.0),
              //SKAction.wait(forDuration: 0.1),
              SKAction.scale(to: 1.0, duration: 1.0)
              //SKAction.run{self.isPaused = true},
            ])
        let loopAction = SKAction.repeatForever(actions)
        node.run(loopAction)
    }
    //MARK:デバッグ用
    //SKShapeNodeのサイズの四角を追加する
    func addBodyFrame(node: SKSpriteNode){
        let frameRect = SKShapeNode(rect: CGRect(x: -node.size.width / 2,
                                                 y: -node.size.height / 2,
                                                 width: node.size.width,
                                                 height: node.size.height))
        frameRect.fillColor = UIColor.clear
        frameRect.lineWidth = 2.0
        frameRect.xScale = 1 / node.xScale  //縮小されている場合はその分拡大する
        frameRect.yScale = 1 / node.yScale  //縮小されている場合はその分拡大する
        frameRect.zPosition = 1500          //とにかく手前
        frameRect.name = "frame"
        node.addChild( frameRect )
    }
    //デバッグ表示用view
    var debugView = UIView()
    let playerPosLabel = UILabel()                                  //プレイヤーの座標表示用ラベル
    let paramNames = ["重力",
                      "隕石の発生位置",
                      "隕石の重力受ける率",
                      "ジャンプ速度",
                      "プレイヤーの重力受ける率",
                      "ガード時の隕石速度",
                      "ガード時のプレイヤー速度"]
    var params = [UnsafeMutablePointer<CGFloat>]()
    let paramMin:[Float] = [0,       //gravity
                            0,       //meteorPos
                            0,       //meteorGravityCoefficient
                            0,       //pleyerJumpSpeed
                            0,       //playerGravityCoefficient
                            0,       //meteorSpeedAtGuard
                            0]       //speedFromMeteorOnGuard
    let paramMax:[Float] = [1000,    //gravity
                            5000,    //meteorPos
                            100,     //meteorGravityCoefficient
                            2000,    //pleyerJumpSpeed
                            100,     //playerGravityCoefficient
                            1000,    //meteorSpeedAtGuard
                            1000]    //speedFromMeteorOnGuard
    let paramTrans = [ {(a: Float) -> CGFloat in return -CGFloat(Int(a)) },
                       {(a: Float) -> CGFloat in return CGFloat(Int(a)) },
                       {(a: Float) -> CGFloat in return CGFloat(Int(a)) / 100 },
                       {(a: Float) -> CGFloat in return CGFloat(Int(a)) },
                       {(a: Float) -> CGFloat in return CGFloat(Int(a)) / 100 },
                       {(a: Float) -> CGFloat in return CGFloat(Int(a)) },
                       {(a: Float) -> CGFloat in return CGFloat(Int(a)) }
    ]
    let paramInv = [ {(a: CGFloat) -> Float in return -Float(a) },
                     {(a: CGFloat) -> Float in return Float(a) },
                     {(a: CGFloat) -> Float in return Float(a * 100) },
                     {(a: CGFloat) -> Float in return Float(a) },
                     {(a: CGFloat) -> Float in return Float(a * 100) },
                     {(a: CGFloat) -> Float in return Float(a) },
                     {(a: CGFloat) -> Float in return Float(a) }
    ]
    //調整用スライダー
    var paramSliders = [UISlider]()
    var paramLabals = [SKLabelNode]()
    var collisionLine : SKShapeNode!
    //追加
    func addParamSlider(){
        /*
        //デバッグ表示関連はすべてdebugViewに追加する
        debugView.frame.size = self.frame.size
        debugView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.view!.addSubview(debugView)
        //
        params.append(&gravity)
        params.append(&meteorPos)
        params.append(&meteorGravityCoefficient)
        params.append(&pleyerJumpSpeed)
        params.append(&playerGravityCoefficient)
        params.append(&meteorSpeedAtGuard)
        params.append(&speedFromMeteorAtGuard)
        //パラメータ調整用スライダー
        var ix = 0;
        for p in paramNames {
            let slider = UISlider()
            slider.center = CGPoint(x: 100, y: frame.midY - 50 + (CGFloat(ix)*50) )
            slider.frame.size.width = frame.size.width - 100
            slider.sizeToFit()
            slider.addTarget(self, action: #selector(self.sliderOnChange), for: .valueChanged)
            slider.minimumValue = paramMin[ix]     // 最小値
            slider.maximumValue = paramMax[ix]    // 最大値
            slider.setValue( paramInv[ix](params[ix].pointee), animated: true)  // デフォルト値の設定
            paramSliders.append(slider)     //検索につかうので配列にも入れておく
            debugView.addSubview(slider)
            //値表示用ラベル
            let label = UILabel()
            label.text = p + ": " + String( describing: params[ix].pointee )
            label.sizeToFit()
            label.textColor = UIColor.white
            label.layer.position.y -= 10
            slider.addSubview(label)
            ix += 1
        }
        //プレイヤー座標
        playerPosLabel.layer.position = CGPoint(x: 10, y:30)
        playerPosLabel.numberOfLines = 10
        playerPosLabel.textColor = UIColor.white
        playerPosLabel.frame.size.width = frame.size.width
        playerPosLabel.frame.size.height = 50
        debugView.addSubview(playerPosLabel)
        //デフォルトボタン
        let btn = UIButton(type: UIButtonType.roundedRect)
        btn.setTitle("Default", for: .normal)
        btn.sizeToFit()
        btn.backgroundColor = UIColor.green
        btn.layer.position = CGPoint(x: btn.frame.size.width,
                                     y: frame.maxY - btn.frame.size.height)
        btn.addTarget(self, action: #selector(self.setDefaultParam), for: .touchUpInside)
        debugView.addSubview(btn)
         */
        //デフォルト非表示
        debugView.isHidden = true
    }
    //削除
    func removeParamSlider(){
        debugView.removeFromSuperview()
    }
    var sliderHidden: Bool = true
    @objc func sliderSwitchHidden( ){
        sliderHidden = !sliderHidden
        debugView.isHidden = sliderHidden
    }
    @objc func setDefaultParam(){
        //調整用パラメータ
        gravity = -900                               //重力 9.8 [m/s^2] * 150 [pixels/m]
        meteorPos = 2400                             //隕石の初期位置
        meteorGravityCoefficient = 0.06              //隕石が受ける重力の影響を調整する係数
        pleyerJumpSpeed = 1500                       //プレイヤーのジャンプ時の初速
        playerGravityCoefficient = 1                 //隕石が受ける重力の影響を調整する係数
        meteorSpeedAtGuard = 100                     //隕石が防御された時の速度
        speedFromMeteorAtGuard = -500                //隕石を防御した時にプレイヤーの速度
        var ix = 0
        for slider in paramSliders {
            slider.setValue( paramInv[ix](params[ix].pointee), animated: true)  // デフォルト値の設定
            let label = slider.subviews.last as! UILabel
            label.text = paramNames[ix] + ": " + String( describing: params[ix].pointee )
            label.sizeToFit()
            ix += 1
        }
    }
    // スライダーの値が変更された時の処理
    @objc func sliderOnChange(_ sender: UISlider) {
        //変更されたスライダーの配列のindex
        let index = paramSliders.index(of: sender)
        //
        params[index!].pointee = paramTrans[index!](sender.value)
        print("###set \(paramNames[index!]): \(sender.value) -> \(params[index!].pointee)")
        let label = sender.subviews.last as! UILabel
        label.text = paramNames[index!] + ": " + String( describing: params[index!].pointee )
        label.sizeToFit()
    }
}
