import router from '@ohos.router';
import ZonesItem from '../viewmodel/ZonesItem';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { DeviceScreen } from '../common/utils/DeviceScreen';
import zonesViewModel from '../viewmodel/ZonesViewModel';
import { RouteTitle } from '../viewmodel/TrainsMap';
import { AnimationItem } from '../viewmodel/AnimationItem'
import DatabaseHelper from '../utils/DatabaseHelper';
import hilog from '@ohos.hilog';
import { museum } from '../models/museum';
import cloud, { AuthUser } from '@hw-agconnect/cloud';
import { userLikes } from '../models/userLikes';
import Prompt from '@system.prompt';
import { userReview } from '../models/userReview';
import picker from '@ohos.file.picker';

@Entry
@Component
struct MyIntroduction {
  @State params: any = router.getParams();
  @StorageLink('user') user: AuthUser = null //获取user,以方便获取user的UID，之后再aboutToAppear()中去初始化一些用到的个人信息
  //在登录界面用AppStorage.SetOrCreate('user',user),第二个user用getUser()去获取
  private on: Resource = $r('app.media.like')
  private off: Resource = $r('app.media.notLike')
  @State zoneList: ZonesItem[] = zonesViewModel.getZonesList();
  @Provide('introductionData') introductionData: ZonesItem = zonesViewModel.getZonesList()[0];
  @State currentZoneId: number = 0;
  @State museumId: string = '10000';
  @State isShowReplay: Array<boolean> = [];
  @State isReachStart: boolean = false;
  @State buildingType: string = Const.BUILDING_TEXT;
  @State homeIconOpacity: number = Const.OPACITY_MIN;
  @Provide animationItem: AnimationItem = new AnimationItem();
  @State isLiked: boolean = false
  @State imgUrl: Resource = this.off //点赞的图片
  @State show: boolean = false
  @State inputData: string = ''
  @State likeNumber: number = 0
  @State ReviewList: userReview[] = []
  @State currentUid: string = ''
  @State currentUserPhotoUrl: string = ''
  @State currentUserName: string = ''
  @State sendImgUrl: string = ''
  controller: TextInputController = new TextInputController();

  getIntroductionData() {
    this.introductionData = this.zoneList.filter((item) => item.id === this.currentZoneId)[0];
    //进行过滤，id等于currentZoneId截取
  }

  async aboutToAppear() {
    // 整改后的代码
    // let params = router.getParams() as Record<string, Object>;
    this.currentZoneId = this.params.id as number; //接受上个页面传来的id
    let t = this.params.id as number
    this.museumId = t.toString()
    hilog.info(0x0000, 'getMuseumId', JSON.stringify(this.museumId))
    this.getIntroductionData();
    this.animationItem.screenHeight = DeviceScreen.getDeviceHeight();
    // let userInfo = await DatabaseHelper.userQueryByUid(this.currentUid)
    //this.currentUserName = userInfo[0].user_name;//这里是从云数据库拿的user信息
    // this.currentUserPhotoUrl = userInfo[0].user_photoUrl


    //全部从auth中拿个人信息，当然登录之后需要设置个人信息
    this.currentUid = this.user.getUid()
    this.currentUserName = this.user.getDisplayName()
    this.currentUserPhotoUrl= this.user.getPhotoUrl()
    hilog.info(0x0000, 'Login', JSON.stringify(this.currentUid))
    hilog.info(0x0000, 'Login', JSON.stringify(this.user))

    try {
      //获取点赞量
      let userLikeData: userLikes[] = await DatabaseHelper.queryLikeNumberByMuseumId(this.museumId)
      // @ts-ignore
      this.likeNumber = userLikeData.length
      hilog.info(0x0000, 'querybyid', JSON.stringify(userLikeData));
      hilog.info(0x0000, 'querybyid', JSON.stringify(this.likeNumber));
    }catch(e){
      hilog.error(0x0000, 'error1', JSON.stringify('获取点赞量出错'));
    }
    try{
      //查询当前用户是否点赞了当前museum
      let temp: userLikes[] = await DatabaseHelper.queryLikeByUIDAndMuseumId(this.currentUid, this.museumId)
      if (temp.length === 0) {
        this.isLiked = false
        this.imgUrl = this.off
      } else {
        this.isLiked = true
        this.imgUrl = this.on
      }
      hilog.info(0x0000, 'querybyid', JSON.stringify(temp));
      hilog.info(0x0000, 'querybyid', JSON.stringify(temp.length));
    }catch (e){
      hilog.error(0x0000, 'error2', JSON.stringify('查询是否点赞量出错'));
    }

    try{
      //获取该文物的评论
      this.ReviewList = await DatabaseHelper.queryReviewByMuseumId(this.museumId) //获取文物评论Json列表
      hilog.info(0x0000, 'getMuseumList', JSON.stringify(this.ReviewList));
      hilog.info(0x0000, 'getMuseumList', JSON.stringify(this.ReviewList.length));
    }catch (e){
      hilog.error(0x0000, 'error3', JSON.stringify('获取评论出错'));
    }

  }

  async sendReview() {
    let newUserReview = new userReview()
    newUserReview.setUid(this.currentUid)
    newUserReview.setId(this.museumId)
    newUserReview.setContent(this.inputData)
    newUserReview.setImageUrl(this.sendImgUrl)
    let upReviewNumber = await DatabaseHelper.upsertReview(newUserReview)

    //重新加载
    this.ReviewList = await DatabaseHelper.queryReviewByMuseumId(this.museumId)
    hilog.info(0x0000, 'upsertReview', JSON.stringify(newUserReview));
    hilog.info(0x0000, 'upsertReview', JSON.stringify(upReviewNumber));
    this.inputData = ''
    this.sendImgUrl = ''
    AlertDialog.show({ message: '评论成功!' });
  }

  build() {
    Stack() {
      // 背景图片层
      Image(this.params.imageUrl)
        .objectFit(ImageFit.Cover)
        .width(Const.FULL_SIZE)
        .height(Const.FULL_SIZE)
        .opacity(0.5) // 设置透明度
        .blur(20); // 添加模糊效果



      // 显示物品详细信息
      if (this.params) {
        Column() {
          // 顶部返回和标题栏
          Row() {
            Image($r('app.media.back'))
              .width(30)
              .onClick(() => {
                router.back();
              })
              .margin({ right: 90 })

            Text('详细信息')
              .fontSize(30)
              .fontWeight(FontWeight.Bold);
          }.width('100%')

          Image(this.params.imageUrl)
            .objectFit(ImageFit.Cover)
            .borderRadius(10)
            .shadow({
              radius: Const.SHADOW_RADIUS,
              color: `rgba(0,0,0,0.3)`,
              offsetY: Const.SHADOW_RADIUS / Const.DOUBLE_NUM
            })
            .height(300);
          Text(this.params.name)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 10, bottom: 10 });

          Column() {
            Text('名  称: ' + this.params.name);
            Text('时  间: ' + this.params.time);
            Text('创作者: ' + this.params.creator);
            Text('级  别: ' + this.params.level);
            Text('来源地: ' + this.params.placeOfOrigin);
            Text('收藏馆: ' + this.params.museum);
            Text('类  型: ' + this.params.type);
            Text('尺  寸: ' + this.params.size);
            Text('材  质: ' + this.params.material);
            Text('文物简介: ' + this.params.description)
              .margin({ bottom: 10 });
          }
          .margin({ left: 0 })
          .alignItems(HorizontalAlign.Start); // 左对齐
        }
        .height(Const.FULL_SIZE)

        //点赞功能
        Column() {
          Image(this.imgUrl)
            .height($r('app.float.page_icon_size'))
            .onClick(async () => {
              this.isLiked = !this.isLiked
              if (this.isLiked === false) {
                this.imgUrl = this.off //取消点赞
                this.likeNumber--;
                //点赞功能
                let temp = new userLikes()
                temp.setId(this.museumId)
                temp.setUid(this.currentUid)
                hilog.info(0x0000, 'cutOn', JSON.stringify(temp));
                let userLikeData = await DatabaseHelper.queryLikeByUIDAndMuseumId(this.currentUid, this.museumId) //获取到整个userLike
                let res = await DatabaseHelper.deleteByMuseumIdAndUserId(userLikeData[0])
                hilog.info(0x0000, 'userDataDelete', JSON.stringify(userLikeData));
                hilog.info(0x0000, 'userDataDelete', JSON.stringify(res));
              } else {
                this.imgUrl = this.on //爱心变亮
                this.likeNumber++;
                let temp = new userLikes()
                temp.setId(this.museumId)
                temp.setUid(this.currentUid)
                hilog.info(0x0000, 'cutOff', JSON.stringify(temp));
                let userLikeData = await DatabaseHelper.queryLikeByUIDAndMuseumId(this.currentUid, this.museumId) //获取到整个userLike
                hilog.info(0x0000, 'cutOff', JSON.stringify(userLikeData));
                if (userLikeData.length === 0) {//如果没有点赞
                  let res = await DatabaseHelper.updataByMuseumIdAndUserId(temp) //返回一个插入的个数
                  hilog.info(0x0000, 'userDataInsert', JSON.stringify(userLikeData));
                  hilog.info(0x0000, 'userDataInsert', JSON.stringify(res));
                }
              }
            })

          Text(`${this.likeNumber}`)
            .margin({bottom:10})

          Image($r('app.media.review'))
            .height($r('app.float.page_icon_size'))
            .onClick(async () => {
              this.ReviewList = await DatabaseHelper.queryReviewByMuseumId(this.museumId)
              hilog.error(0x0000, 'getReviewList', JSON.stringify(this.ReviewList))
              this.show = !this.show
              hilog.error(0x0000, 'getReviewList', JSON.stringify(this.show))
            })

          Text(`${this.ReviewList.length}`)
        }
        .margin({ bottom: vp2px(30), left: $r('app.float.page_icon_margin_vertical') })




        //评论功能
        Panel(this.show) {
          Row({ space: 5 }) {
            TextInput({ placeholder: '请输入评论的内容', text: this.inputData,
              controller: this.controller })
              .onChange((value) => {
                this.inputData = value
              })
              .onSubmit(async () => {
                this.sendReview()
              })
              .width(200)
              .margin({ left: 1 })

            Image($r('app.media.submit')) //评论提交按钮
              .onClick(async () => {
                this.sendReview()
              })
              .height(30)
              .margin({ left: 15 })

            Image($r('app.media.upImage')) //评论图片的功能
              .height(30)
              .margin({ left: 15 })
              .onClick(async () => {
                //从相册选择图片或者视频
                try {
                  const options = new picker.PhotoSelectOptions();
                  options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE
                  options.maxSelectNumber = 1;
                  const result = await new picker.PhotoViewPicker().select(options)
                  hilog.info(0x0000, 'uploadImage', JSON.stringify(result));
                  //调云存储api去上传图片
                  const currentTime = new Date().getTime().toString()
                  await cloud.storage().upload({
                    localPath: result.photoUris[0],
                    cloudPath: `zpptest/${this.currentUid}${currentTime}.jpg`
                  })
                  //下面这里需要用户登录之后才能进行
                  hilog.info(0x0000, 'uploadImage', 'success');
                  //获取上传照片的网络地址
                  const url = await cloud.storage().getDownloadURL(`zpptest/${this.currentUid}${currentTime}.jpg`)
                  this.sendImgUrl = `${url}&ts=${new Date().getTime()}`
                  hilog.info(0x0000, 'uploadImage', `url: ${this.sendImgUrl}}`);
                  this.sendReview()

                } catch (e) {
                  hilog.info(0x0000, 'uploadImage', JSON.stringify(e));
                }
              })

            Image($r('app.media.back'))
              .onClick(() => {
                this.show = false
              })
              .height(30)
              .margin({ left: 15 })

          }.justifyContent(FlexAlign.SpaceEvenly)


          //评论列表
          List({ space: 4, scroller: this.animationItem.scrollerForList }) {
            ForEach(this.ReviewList, (item: userReview, index) => {
              ListItem() {
                Column() {
                  Row() {
                    //之后这里应该是要加上user表中的username和头像，这里头像不需要自己解决云存储，但是需要解决可以上传图片的云存储
                    Column({ space: 8 }) {
                      Image(this.currentUserPhotoUrl)
                        .width(30)
                        .margin({ left: 10 })

                      Text(this.currentUserName)
                        .margin({ left: 20 })
                        .width(25)
                        .fontSize(10)
                    }

                    Text(":  " + item.content)
                      .textAlign(TextAlign.Start)
                      .margin({ left: 8 })

                    Image(item.imageUrl)
                      .margin({ left: 8 })
                      .width(50)
                  }

                  Row() {
                    Image($r('app.media.split')).height(5)
                    Image($r('app.media.split')).height(5)
                    Image($r('app.media.split')).height(5)
                    Image($r('app.media.split')).height(5)
                    Image($r('app.media.split')).height(5)
                  } //每行评论之间的分割线
                }
                .margin(5)
              }
            })
          }
          .divider({ strokeWidth: 2, color: 0xFFFFFF, startMargin: 20, endMargin: 20 }) // 每行之间的分界线
          .layoutWeight(1)
        }
        .type(PanelType.Foldable)
        .mode(PanelMode.Half)
        .dragBar(true) // 默认开启
        .halfHeight(500) // 默认一半
        .onChange((width: number, height: number, mode: PanelMode) => {
          console.info(`width:${width},height:${height},mode:${mode}`)
        })
        .height(Const.FULL_SIZE)
        .layoutWeight(1)

      }

    }.backgroundColor($r('app.color.introduction_page_color'))
    .height(Const.FULL_SIZE)
  }
}
