//
//  GameScene.swift
//
import UIKit
import SpriteKit
import AVFoundation
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
    let backScrNode = SKNode()                                      //背景ノード
    var player: SKSpriteNode!                                       //プレイヤーノード
    var ground: SKSpriteNode!                                       //地面
    var lowestShape: SKShapeNode!                                   //落下判定シェイプノード
    var attackShape: SKShapeNode!                                   //攻撃判定シェイプノード
    var guardShape: SKShapeNode!                                    //防御判定シェイプノード
    var startNode: SKSpriteNode!
    var start0Node: SKSpriteNode!
    let scoreLabel = SKLabelNode()                                  //スコア表示ラベル
    var score = 0                                                   //スコア
    var ultraButtonString: String = "zan.png"
    var ultraButton: SKSpriteNode!
    var ultraOkButton: SKSpriteNode!
    
    //MARK: 画面
    var allScreenSize = CGSize(width: 0, height: 0)                 //全画面サイズ
	let oneScreenSize = CGSize(width: 375, height: 667)             //１画面サイズ
    
    //MARK: タイマー
    var meteorTimer: Timer?                                         //隕石用タイマー
    
    //MARK: フラグ
    var gameoverFlg : Bool = false                                  //ゲームオーバーフラグ
    var attackFlg : Bool = false                                    //攻撃フラグ
    var guardFlg : Bool = false                                     //ガードフラグ
    var moving: Bool = false                                        //移動中フラグ
    var jumping: Bool = false                                       //ジャンプ中フラグ
    var falling: Bool = false                                       //落下中フラグ
    var centerPosFlg: Bool = true                                   //中央位置フラグ
    var leftPosFlg: Bool = false                                    //左位置フラグ
    var rightPosFlg: Bool = false                                   //右位置フラグ
    var firstBuildFlg: Bool = true
    var buildFlg:Bool = true
    var gameFlg:Bool = false
    var canMoveFlg = true
    
    //MARK: - プロパティ
	//MARK: プレイヤーキャラプロパティ
	var playerAcceleration: CGFloat = 50.0                          //移動加速値
	var playerMaxVelocity: CGFloat = 300.0                          //MAX移動値
	var jumpForce: CGFloat = 60.0                                   //ジャンプ力
    var guardForce: CGFloat = -10.0                                  //ガード反発力
	var charXOffset: CGFloat = 0                                    //X位置のオフセット
	var charYOffset: CGFloat = 0                                    //Y位置のオフセット
    var guardPower : Int = 500                                      //ガード可否判定用
    var UltraPower : Int = 0                                        //必殺技可否判定用
    
    //MARK: ポジションプロパティ
    let centerPosition = CGPoint(x: 187.5, y: 243.733)              //中央位置
    let leftPosition = CGPoint(x: 93.75, y: 243.733)                //左位置
    let rightPosition = CGPoint(x: 281.25, y: 243.733)              //右位置
    
    //MARK: 隕石・プレイヤー動作プロパティ
    var playerSpeed : CGFloat = 0.0                                 //プレイヤーの速度
    var playerAcc   : CGFloat = 0.0                                 //プレイヤーの加速度
    var meteorSpeed : CGFloat = 0.0                                 //隕石のスピード[pixels/s]
    //調整用パラメータ
    let gravity : CGFloat = -9.8 * 150                  //重力 9.8 [m/s^2] * 150 [pixels/m]
    let meteorPos = 1500.0                              //隕石の初期位置
    let meteorGravityCoefficient: CGFloat = 1/5         //隕石が受ける重力の影響を調整する係数
    let pleyerJumpSpeed : CGFloat = 9.8 * 150 * 1.2     //プレイヤーのジャンプ時の初速
    let playerGravityCoefficient: CGFloat = 1           //隕石が受ける重力の影響を調整する係数
    let meteorGuardSpeed: CGFloat = 9.8 * 150 / 10      //隕石が防御された時の速度
    let playerGuardMeteorSpeed : CGFloat = 1.0          //隕石を防御した時にプレイヤーが受ける隕石の速度の割合

    //MARK: タッチ関係プロパティ
    var beganPos: CGPoint = CGPoint.zero
	var tapPoint: CGPoint = CGPoint.zero
    var beganPyPos: CGFloat = 0.0
    var endPyPos:CGFloat = 0.0
    var movePyPos:CGFloat = 0.0
    
    //MARK: 画面移動プロパティ
	var screenSpeed: CGFloat = 28.0
	var screenSpeedScale: CGFloat = 1.0
    
    var pCamera: SKCameraNode?
    
    //MARK: BGM
    var audioPlayer: AVAudioPlayer!
    
    //MARK: - 関数定義 シーン関係
	//MARK: シーンが表示されたときに呼ばれる関数
	override func didMove(to view: SKView)
    {
        //MARK: カメラ
        let camera = SKCameraNode()
        self.addChild(camera)
        self.camera = camera
        print("---カメラのスタート位置は\(self.camera!.position)です---")
        
        //MARK: 設定関係
        self.backgroundColor = SKColor.clear                        //背景色
        self.physicsWorld.contactDelegate = self                    //接触デリゲート
        self.physicsWorld.gravity = CGVector(dx:0, dy:0)         //重力設定
        
		//MARK: 背景
        self.addChild(self.baseNode)
        self.addChild(self.backScrNode)                             //背景追加
 
        //MARK: ゲーム進行関係
        self.meteorTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.fallMeteor), userInfo: nil, repeats: true)                                          //タイマー生成
        
        //MARK: 音楽
        let soundFilePath: String = Bundle.main.path(forResource: "bgmn", ofType: "mp3")!
        let fileURL: URL = URL(fileURLWithPath: soundFilePath)
        try! audioPlayer = AVAudioPlayer(contentsOf: fileURL)
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay()

		//MARK: SKSファイルを読み込み
		if let scene = SKScene(fileNamed: "GameScene.sks")
        {
            //===================
			//MARK: 背景
			//===================
			scene.enumerateChildNodes(withName: "back_wall", using:
            { (node, stop) -> Void in
				let back_wall = node as! SKSpriteNode
				back_wall.name = "backGround"
				//シーンから削除して再配置
				back_wall.removeFromParent()
				self.backScrNode.addChild(back_wall)
                print("---SKSファイルより背景＝\(back_wall)を読み込みました---")
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
                print("---SKSファイルより地面＝\(ground)を読み込みました---")
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
                print("---SKSファイルより落下判定シェイプノード＝\(lowestShape)を読み込みました---")
            })
            //===================
			//MARK: プレイヤー
			//===================
            self.charXOffset = self.oneScreenSize.width * 0.5
			self.charYOffset = self.oneScreenSize.height * 0.5
			scene.enumerateChildNodes(withName: "player", using: { (node, stop) -> Void in
				let player = node as! SKSpriteNode
                player.name = "player"
                player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64), center: CGPoint(x: 0, y: 0))
                player.physicsBody!.friction = 1.0                      //摩擦
                player.physicsBody!.allowsRotation = false              //回転禁止
                player.physicsBody!.restitution = 0.0                   //跳ね返り値
                player.physicsBody!.mass = 0.03                         //質量
                player.physicsBody?.categoryBitMask = 0b0100            //接触判定用マスク設定
                player.physicsBody?.collisionBitMask = 0b0001           //接触対象を地面に設定
                player.physicsBody?.contactTestBitMask = 0b1000 | 0b0001//接触対象を地面｜meteorに設定
                //シーンから削除して再配置
				player.removeFromParent()
				self.baseNode.addChild(player)
                self.player = player
                print("---SKSファイルよりプレイヤー＝\(player)を読み込みました---")
                //アニメーション
                let names = ["stand01","stand02"]
                self.startStandTextureAnimation(player, names: names)
            })
            if( debug ){ //デバッグ用
                addBodyFrame(node: player)  //枠表示
            }
            //===================
            //MARK: スコア
            //===================
            self.scoreLabel.text = String( self.score )         //スコアを表示する
            self.scoreLabel.position = CGPoint(                 //表示位置をplayerのサイズ分右上に
                x: self.player.size.width + 100,
                y: self.player.size.height
            )
            self.scoreLabel.xScale = 1 / self.player.xScale     //playerが縮小されている分拡大して元の大きさで表示
            self.scoreLabel.yScale = 1 / self.player.yScale
            self.player.addChild(self.scoreLabel)               //playerにaddchiledすることでplayerに追従させる
			
            //===================
            //MARK: 必殺技ボタン
            //===================
            ultraButton = SKSpriteNode(imageNamed: ultraButtonString)
            self.ultraButton.position = CGPoint(                 //表示位置をplayerのサイズ分右上に
                x: self.player.size.width - 250,
                y: self.player.size.height + 50
            )
            self.ultraButton.xScale = 1 / self.player.xScale     //playerが縮小されている分拡大して元の大きさで表示
            self.ultraButton.yScale = 1 / self.player.yScale
            self.player.addChild(self.ultraButton)               //playerにaddchiledすることでplayerに追従させる
            
            ultraOkButton = SKSpriteNode(imageNamed: "renzan.png")
            self.ultraOkButton.position = CGPoint(                 //表示位置をplayerのサイズ分右上に
                x: self.player.size.width - 400,
                y: self.player.size.height + 50
            )
            self.ultraOkButton.xScale = 1 / self.player.xScale     //playerが縮小されている分拡大して元の大きさで表示
            self.ultraOkButton.yScale = 1 / self.player.yScale
            ultraOkButton.removeFromParent()
            self.player.addChild(self.ultraOkButton)               //playerにaddchiledすることでplayerに追従させる
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
            //MARK: startNode
            //===================
            scene.enumerateChildNodes(withName: "startNode", using: { (node, stop) -> Void in
                let startNode = node as! SKSpriteNode
                startNode.name = "startNode"
                //シーンから削除して再配置
                startNode.removeFromParent()
                self.startNode = startNode
                self.baseNode.addChild(startNode)
                startNode.isUserInteractionEnabled = false
            })
            //===================
            //MARK: start0Node
            //===================
            scene.enumerateChildNodes(withName: "start0Node", using: { (node, stop) -> Void in
                let start0Node = node as! SKSpriteNode
                start0Node.name = "start0Node"
                //シーンから削除して再配置
                start0Node.removeFromParent()
                self.start0Node = start0Node
                self.baseNode.addChild(start0Node)
            })
            //===================
            //MARK:  リスタートボタン
            //===================
            /*let reStartButton = UIButton()
            reStartButton.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            reStartButton.backgroundColor = UIColor.red;
            reStartButton.layer.masksToBounds = true
            reStartButton.setTitle("restart!", for: <#T##UIControlState#>)
            reStartButton.setTitleColor(UIColor.white, for: UIControlState)
            reStartButton.setTitle("Done", forState: UIControlState.Highlighted)
            myButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
            myButton.layer.cornerRadius = 20.0
            myButton.layer.position = CGPoint(x: self.view!.frame.width/2, y:200)
            myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
            self.view!.addSubview(myButton);
 */
		}
	}
    
    //MARK: シーンのアップデート時に呼ばれる関数
    override func update(_ currentTime: TimeInterval) {
        if ( !meteores.isEmpty ){
            self.meteorSpeed += self.gravity * meteorGravityCoefficient / 60
            for m in meteores{
                m.position.y += self.meteorSpeed / 60
            }
        }
        if (jumping == true || falling == true){
            // 次の位置を計算する
            self.playerSpeed += self.gravity * self.playerGravityCoefficient / 60   // [pixcel/s^2] / 60[fps]
            self.player.position.y = self.player.position.y + CGFloat( playerSpeed / 60 ) // [pixcel/s] / 60[fps]
        }
        if (jumping == true || falling == true) && (self.player.position.y > self.oneScreenSize.height/2)
        {
            self.camera!.position = CGPoint(x: self.oneScreenSize.width/2,y: self.player.position.y);
        }
        else {
            self.camera!.position = CGPoint(x: self.oneScreenSize.width/2,y: self.oneScreenSize.height/2)
        }
        
        if self.player.physicsBody?.velocity.dy < -9.8 && self.falling == false
        {
            self.jumping = false
            self.falling = true
        }
        /*if self.player.position.y > self.meteores.last!.position.y - self.meteores.last!.size.height/2
        {
            self.player!.position.y = meteores.last!.position.y - meteores.last!.size.height/2
        }
        */
        if (guardPower < 500)
        { guardPower += 1
        }
        else
        {
         return
        }
    }
    
    //MARK: すべてのアクションと物理シミュレーション処理後、1フレーム毎に呼び出される
    override func didSimulatePhysics() {
    }
    
    //MARK: - 関数定義　タッチ処理
    //MARK: タッチダウンされたときに呼ばれる関数
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first as UITouch?
        {
            beganPos = touch.location(in: self)
            beganPyPos = player!.position.y
            let node:SKSpriteNode? = self.atPoint(beganPos) as? SKSpriteNode;
            print("---タップを離したノード=\(String(describing: node?.name))---")
            if node == nil
            {
                return
            }
            else if node?.name == "start0Node"
            {
                startButtonAction()
                start0Node.zPosition = -15
            }
        }
    }

    //MARK: タッチ移動されたときに呼ばれる関数
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let endedPos = touch.location(in: self)
            let xPos = beganPos.x - endedPos.x
            let yPos = beganPos.y - endedPos.y
            if fabs(yPos) > fabs(xPos)  {
                if yPos > 0  {              //下スワイプ
                    return
                } else if yPos < 0 {        //上スワイプ
                    return
                }
            } else {
                if xPos > 100 {             //左スワイプ
                    return
                } else if xPos < -100 {     //右スワイプ
                    return
                }
            }
        }
    }
    
    //MARK: タッチアップされたときに呼ばれる関数
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch: AnyObject in touches
        {
            let endPos = touch.location(in: self)
            let xPos = beganPos.x - endPos.x
            let yPos = beganPos.y - endPos.y
            endPyPos = player.position.y
            movePyPos = endPyPos - beganPyPos
            let moveY = beganPos.y + movePyPos - endPos.y
            print("---beganPos.y=\(beganPos.y),movePyPos=\(movePyPos),endPos.y=\(endPos.y),moveY=\(moveY)---")
            print("---xPos=\(xPos),yPos=\(yPos)---")
            if (self.player.position.y > self.oneScreenSize.height/2) && (canMoveFlg == true)
            {
                if (jumping == true || falling == true) && (-10...10 ~= moveY) && (-10...10 ~= xPos)
                {
                    attackAction()
                    print("---jumpingアタック---")
                }
                else if (jumping == true || falling == true) && (moveY > 10)
                {
                    guardAction()
                    print("---jumpingガード---")
                }
            }
            else if (self.player.position.y < self.oneScreenSize.height/2) && (canMoveFlg == true)
            {
                if (jumping == false || falling == false) && (fabs(yPos) == fabs(xPos))
                {
                    attackAction()
                    print("---groundアタック---")
                }
                else if yPos > 50
                {
                    self.guardAction()
                    print("---groundガード---")
                }
                else if yPos < -50
                {
                    self.jumpingAction()
                    print("---groundアタック---")
                }
                else if xPos > 50
                {
                    self.moveToLeft()
                    print("---左スワイプ---")
                }
                else if xPos < -50
                {
                    self.moveToRight()
                    print("---右スワイプ---")
                }
            }
            let node:SKSpriteNode? = self.atPoint(endPos) as? SKSpriteNode;
            print("---タップを離したノード=\(String(describing: node?.name))---")
            if node == nil
            {
                return
            }
            else if node?.name == "startNode"
            {
                print("hello")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                {
                    self.canMoveFlg = true
                 }
                self.isPaused = false
                self.meteorTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.fallMeteor), userInfo: nil, repeats: true)
                let move1 = SKAction.moveBy(x: 0, y: 80, duration: 0.4)
                let move2 = SKAction.wait(forDuration: 0.4)
                let move3 = SKAction.moveBy(x: 0, y: -2300, duration: 10.0)
                let move4 = SKAction.sequence([move1,move2,move3])
                for i in meteores
                {
                    i.removeAllActions()
                    i.run(move4)
                    print("---隕石がガードされたモーションを実行---")
                }
                startNode.zPosition = -15
            }
        }
    }
    
    //MARK: - 移動
    let moveL = SKAction.moveTo(x: 93.75, duration: 0.15)
    let moveC = SKAction.moveTo(x: 187.5, duration: 0.15)
    let moveR = SKAction.moveTo(x: 281.25, duration: 0.15)
    
    //MARK: - 右移動
    func moveCtoR() {
        if (jumping == false) && (falling == false) {
            centerPosFlg = false
            leftPosFlg = false
            rightPosFlg = true
            moving = true
            let names = ["attack01","attack02","player00"]
            self.attackTextureAnimation(self.player, names: names)
            player.run(moveR)
            playSound(soundName: "move")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.moveStop()
            }
        }
    }
    func moveLtoC() {
        if (jumping == false) && (falling == false) {
            centerPosFlg = true
            leftPosFlg = false
            rightPosFlg = false
            moving = true
            let names = ["attack01","attack02","player00"]
            attackTextureAnimation(self.player, names: names)
            player.run(moveC)
            playSound(soundName: "move")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.moveStop()
            }
        }
    }
    func moveToRight() {
        if centerPosFlg == true { moveCtoR()
        } else if leftPosFlg == true { moveLtoC()
        }
    }
    
    //MARK: - 左移動
    func moveCtoL() {
        if (jumping == false) && (falling == false) {
            centerPosFlg = false
            leftPosFlg = true
            rightPosFlg = false
            let names = ["attack01","attack02","player00"]
            attackTextureAnimation(self.player, names: names)
            player.run(moveL)
            playSound(soundName: "move")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.moveStop()
            }
        }
    }
    func moveRtoC() {
        if self.jumping == false && self.falling == false {
            centerPosFlg = true
            leftPosFlg = false
            rightPosFlg = false
            let names = ["attack01","attack02","player00"]
            attackTextureAnimation(self.player, names: names)
            player.run(moveC)
            playSound(soundName: "move")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.moveStop()
            }
        }
    }
    func moveToLeft() {
        if centerPosFlg == true { moveCtoL()
        } else if rightPosFlg == true { moveRtoC()
        }
    }
    
    //MARK: - 停止
    func moveStop() {
        moving = false
        if (jumping == false) && (self.falling == false) {
            self.player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        }
        let names = ["stand01","stand02"]
        self.startStandTextureAnimation(player, names: names)
    }
    
    //MARK: - ジャンプ
    func jumpingAction() {
        if (jumping == false) && (falling == false) {
            moving = false
            jumping = true
            playerSpeed = pleyerJumpSpeed
            playSound(soundName: "jump")
        }
    }
    
    //MARK: - 関数定義　接触判定
    func didBegin(_ contact: SKPhysicsContact) {
        print("---didBeginで衝突しました---")
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        let nameA = nodeA?.name
        let nameB = nodeB?.name
        let bitA = contact.bodyA.categoryBitMask
        let bitB = contact.bodyB.categoryBitMask
        print("---接触したノードは\(String(describing: nameA))と\(String(describing: nameB))です---")
        
        if (bitA == 0b10000 || bitB == 0b10000) && (bitA == 0b1000 || bitB == 0b1000)
        {
            print("---MeteorとattackShapeが接触しました---")
            attackMeteor()
        }
        else if (bitA == 0b100000 || bitB == 0b100000) && (bitA == 0b1000 || bitB == 0b1000)
        {
            print("---MeteorとguardShapeが接触しました---")
            guardMeteor()
        }
        else if (bitA == 0b0010 || bitB == 0b0010) && (bitA == 0b1000 || bitB == 0b1000)
        {
            print("---MeteorとGameOverが接触しました---")
            gameOver()
        }
        else if (bitA == 0b0100 || bitB == 0b0100) && (bitA == 0b0001 || bitB == 0b0001)
        {
            print("---Playerと地面が接触しました---")
            jumping = false
            falling = false
            playSound(soundName: "tyakuti")
            self.playerSpeed = 0.0
            self.playerAcc = 0.0
        }
        else if (bitA == 0b0100 || bitB == 0b0100) && (bitA == 0b1000 || bitB == 0b1000)
        {
            self.playerSpeed = self.meteorSpeed
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        print("------------didEndで衝突しました------------")
        print("bodyA:\(contact.bodyA)")
        print("bodyB:\(contact.bodyB)")
        return
    }
    
    //MARK: - 関数定義　自分で設定関係
    
    //MARK: 配列
    var meteorNames: [String] = ["150","250","350","450"]
    var meteorInt: Int = 0
    var meteorDouble: Double = 70.0
    var meteores: [SKSpriteNode] = []
    var attackShapes: [SKShapeNode] = []
    var guardShapes: [SKShapeNode] = []
    
    //MARK: 隕石落下
    func buildMeteor(size: Double, meteorString: String, meteorZ: Double){
        firstBuildFlg = false
        buildFlg = false
        let texture = SKTexture(imageNamed: meteorString)
        let meteor = SKSpriteNode(texture: texture)
        meteor.position = CGPoint(x: 187, y: self.meteorPos)
        meteor.zPosition = CGFloat(meteorZ)
        meteor.size = CGSize(width: texture.size().width, height: texture.size().height)
        meteor.xScale = CGFloat(size / 150)
        meteor.yScale = CGFloat(size / 150)
        meteor.physicsBody = SKPhysicsBody(texture: texture, size: meteor.size)
        meteor.physicsBody?.affectedByGravity = false
        meteor.physicsBody?.categoryBitMask = 0b1000                         //接触判定用マスク設定
        meteor.physicsBody?.collisionBitMask = 0b0000                        //接触対象をなしに設定
        meteor.physicsBody?.contactTestBitMask = 0b0010 | 0b10000 | 0b100000 | 0b0100 //接触対象を各Shapeとプレイヤーに設定
        meteor.name = "meteor"//meteorString
        self.addChild(meteor)
        print("---meteor\(meteorString)を生成しました---")
        self.meteores.append(meteor)
        if( debug ){    //デバッグ用
            addBodyFrame(node: meteor)  //枠を表示
        }
        /*
        let moveG = SKAction.moveBy(x: 0, y: -3500, duration: 10.0)
        meteor.run(moveG)
        */
        print("---meteor\(meteorString)がmoveGを開始しました---")
    }
    func startButtonAction()
    {
        gameFlg = true
        play()
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
            buildMeteor(size: 150.0, meteorString: "150", meteorZ: 6.0)
        }
        else if buildFlg == false
        {
            return
        }
        else if buildFlg == true
        {
            meteorInt += 1
            meteorDouble = 70.0
            self.meteorSpeed = 0.0
            for i in (0...meteorInt).reversed()
            {
                meteorDouble -= 1.0
                buildMeteor(size: Double(150 + (i * 100)),meteorString: meteorNames[0], meteorZ: meteorDouble)
                print("---meteorInt = \(i)です-----")
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
        attackShape.name = "attackShape"
        let physicsBody = SKPhysicsBody(rectangleOf: attackShape.frame.size)
        attackShape.position = CGPoint(x: self.player.position.x, y: self.player.position.y)
        attackShape.fillColor = UIColor.clear
        attackShape.zPosition = 7.0
        attackShape.physicsBody = physicsBody
        attackShape.physicsBody?.affectedByGravity = false      //重力判定を無視
        attackShape.physicsBody?.isDynamic = false              //固定物に設定
        attackShape.physicsBody?.categoryBitMask = 0b10000      //接触判定用マスク設定
        attackShape.physicsBody?.collisionBitMask = 0b0000      //接触対象をなしに設定
        attackShape.physicsBody?.contactTestBitMask = 0b1000    //接触対象をmeteorに設定
        self.addChild(attackShape)
        print("---attackShapeを生成しました---")
        self.attackShapes.append(attackShape)
    }
    
    func attackAction()
    {
        if canMoveFlg == true
        {
        print("---アタックフラグをON---")
        attackFlg = true
        let names = ["attack01","attack02","player00"]
        self.attackTextureAnimation(self.player, names: names)
        playSound(soundName: "slash")
        attackShapeMake()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                self.attackFlg = false
                self.attackShapes[0].removeFromParent()
                self.attackShapes.remove(at: 0)
                print("---アタックフラグをOFF---")
            }
        }
        else
        {
            return
        }
    }
    
    func attackMeteor()
    {
        if attackFlg == true
        {
            print("---隕石を攻撃---")
            if meteores.isEmpty == false
            {
                attackShapes[0].physicsBody?.categoryBitMask = 0
                attackShapes[0].physicsBody?.categoryBitMask = 0
                meteores[0].physicsBody?.categoryBitMask = 0
                meteores[0].physicsBody?.contactTestBitMask = 0
                meteores[0].removeFromParent()
                print("---消すノードは\(meteores[0])です---")
                meteores.remove(at: 0)
                UltraPower += 1
                print("---UltraPowerは\(UltraPower)です---")
                //スコア
                self.score += 1;
                self.scoreLabel.text = String( self.score )
                if UltraPower >= 10
                {
                    ultraButton.isHidden = true
                    ultraOkButton.isHidden = false
                }
                playSound(soundName: "hakai")
            }
            if meteores.isEmpty == true
            {
                buildFlg = true
                print("---meteoresが空だったのでビルドフラグON---")
            }
        }
    }
    
    //MARK: 防御
    func guardShapeMake()
    {
        let guardShape = SKShapeNode(rect: CGRect(x: 0.0 - self.player.size.width/2, y: 0.0 - self.player.size.height/2, width: self.player.size.width, height: self.player.size.height))
        guardShape.name = "guardShape"
        let physicsBody = SKPhysicsBody(rectangleOf: guardShape.frame.size)
        guardShape.position = CGPoint(x: self.player.position.x, y: self.player.position.y)
        guardShape.fillColor = UIColor.clear
        guardShape.zPosition = 7.0
        guardShape.physicsBody = physicsBody
        guardShape.physicsBody?.affectedByGravity = false      //重力判定を無視
        guardShape.physicsBody?.isDynamic = false              //固定物に設定
        guardShape.physicsBody?.categoryBitMask = 0b100000     //接触判定用マスク設定
        guardShape.physicsBody?.collisionBitMask = 0b0000      //接触対象をなしに設定
        guardShape.physicsBody?.contactTestBitMask = 0b1000    //接触対象をmeteorに設定
        self.addChild(guardShape)
        print("---guardShapeを生成しました---")
        self.guardShapes.append(guardShape)
    }
    
    func guardAction()
    {
        if (canMoveFlg == true && guardPower >= 500)
        {
            print("---ガードフラグをON---")
            guardFlg = true
            let names = ["guard01","player00"]
            self.guardTextureAnimation(self.player, names: names)
            guardShapeMake()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                self.guardFlg = false
                self.guardShapes[0].removeFromParent()
                self.guardShapes.remove(at: 0)
                print("---ガードフラグをOFF---")
            }
        }
        else
        {
            return
        }
    }
    
    func guardMeteor()
    {
        if (guardFlg == true)
        {
            print("---隕石をガード---")
            playSound(soundName: "bougyo")
            //guardPower -= 50
            for i in meteores
            {
                i.removeAllActions()
                self.playerSpeed += self.meteorSpeed * self.playerGuardMeteorSpeed //ガード隕石の速度分プレイヤーの速度が上がる
                self.meteorSpeed = self.meteorGuardSpeed //上に持ちあげる
                print("---隕石がガードされたモーションを実行---")
            }
        }
        else
        {
            print("---guardShapeとmeteorが衝突したけどフラグOFFでした---")
            return
        }
    }
    //MARK: ゲームオーバー処理
    func makeStartNode()
    {    }
    
    func gameOver()
    {
        gameoverFlg = true
        canMoveFlg = false
        makeStartNode()
        startNode.zPosition = 6
        self.isPaused = true
        self.meteorTimer?.invalidate()
        print("------------gameover------------")
        stop()
        newGame()
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
        frameRect.zPosition = 1000          //とにかく手前
        frameRect.name = "frame"
        node.addChild( frameRect )
    }
}
