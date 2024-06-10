import cloud, { AuthUser } from '@hw-agconnect/cloud'
import hilog from '@ohos.hilog'
import router from '@ohos.router'
import picker from '@ohos.file.picker'
import promptAction from '@ohos.promptAction'

//个人主页和个人设置的组件全在这个里面。setPersonalInfo的页面和组件已弃用

@Extend(Text) function card(){
  .fontSize(22)
}

@Component
export struct homepage{
  @State showflag:number=0
  @State photoUrl:string =''
  @State displayName:string =''
  build(){
    if(this.showflag==0){
      PersonalHomepage({showflag:$showflag,photoUrl:$photoUrl,displayName:$displayName})
    }else if(this.showflag==1){
      SetPersonalInfo({showflag:$showflag,photoUrl:$photoUrl,displayName:$displayName})
    }
  }
}

@Component
export struct PersonalHomepage {
  @Link showflag:number
  @Link photoUrl:string
  @Link displayName:string
  @StorageLink('user') user: AuthUser = null

  aboutToAppear(){
    this.displayName = this.user?.getDisplayName()
    this.photoUrl = this.user?.getPhotoUrl()
  }

  build() {
    Column({space:10}){
      Row(){
        Text("个人主页")
          .fontSize(28)
          .fontColor(Color.Grey)
      }
      .width('100%')
      .margin({bottom:5})
      .justifyContent(FlexAlign.Center)

      Divider()
        .width('90%')
        .margin({bottom:10})

      //头像
      Row(){
        Image(this.photoUrl ? this.photoUrl : $r('app.media.icon_profile'))
          .width(120)
          .height(120)
          .borderRadius(70)

      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      //用户名
      Row() {
        Text("用户名："+this.displayName?this.displayName:"momo")
          .card()
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Column(){
        Row(){
          Image($r('app.media.icon_modify'))
            .width('5%')
          Text(' 修改个人信息')
            .card()

          // Button('刷新')
          //   .onClick(()=>{
          //     this.displayName = this.user?.getDisplayName()
          //     this.photoUrl = this.user?.getPhotoUrl()
          //   })
          //   .height(18)
          //   .margin({left:10})
        }
        .onClick(()=>{
          //router.pushUrl({url:'pages/setPersonalInfo'
          this.showflag=1
        })
        .margin(5)

        Row(){
          Image($r('app.media.icon_likes'))
            .width('5%')
          Text('我的喜欢')
            .card()
        }
        .margin(5)
        .onClick(()=>{
          router.pushUrl({url:'pages/myLikes'})
        })

        Row(){
          Image($r('app.media.icon_likes'))
            .width('5%')
          Text('我的评论')
            .card()
        }
        .margin(5)
        .onClick(()=>{
          router.pushUrl({url:'pages/myComment'})
        })

        Row(){
          Image($r('app.media.icon_feedback'))
            .width('5%')
          Text('意见反馈')
            .card()
            .onClick(()=>{
              router.pushUrl({url:'pages/feedback'})
            })
        }
        .margin(5)

        Row(){
          Image($r('app.media.icon_aboutUs'))
            .width('5%')
          Text('关于我们')
            .card()
            .onClick(()=>{
              router.pushUrl(
                {
                  url:'pages/aboutUs'
                },
                router.RouterMode.Single,//页面实例模式，枚举类型
                err=>{ //异常回调函数，错误码，100001：内部错误，可能是渲染失败，100002：路由地址错误，100003：栈>32
                  if(err){
                    console.log('fail')
                  }
                }
              )
            })
        }
        .margin(5)
        Button('登出')
          .onClick(
            async()=>{
              try{
                await cloud.auth().signOut()
                hilog.info(0,'SignOut','success')
                router.replaceUrl({ url: 'pages/login' })
              }catch (e){
                hilog.info(0,'SignOut',JSON.stringify(e))
              }
            }
          )
          .margin({top:20})
      }.margin({top:30}).width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
export struct SetPersonalInfo  {
  @Link photoUrl:string
  @Link displayName:string
  @Link showflag:number
  @StorageLink('user') user: AuthUser = null
  @State uploading: boolean = false
  @State uploadingText: string = '0%'

  //获取用户信息，在用户界面渲染之前
  aboutToAppear(){
    this.displayName = this.user?.getDisplayName()
    this.photoUrl = this.user?.getPhotoUrl()
  }

  build() {
    Row() {
      Column({space:10}) {
        Stack() {
          Image(this.photoUrl ? this.photoUrl : $r('app.media.icon_profile')) //如果没有值设置默认头像
            .width(70)
            .height(70)
            .borderRadius(70)
            .enabled(!this.uploading)
            .onComplete(() => {
              this.uploading = false
            })
            .onClick(async () => {
              try {
                // 1. 从相簿中选照片
                const options = new picker.PhotoSelectOptions()
                options.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE //媒体类型：照片/视频/所有
                options.maxSelectNumber = 1 //最大选择数量
                const result = await new picker.PhotoViewPicker().select(options) //返回promise
                hilog.info(0, 'Upload', `Picker Success ${result.photoUris[0]}`)
                this.uploading = true
                const cloudpath=`userProfile/${this.user.getUid()}_${new Date().getTime()}.jpg` //加上当前时间戳上传用户头像，以防止覆盖原图
                // 2. 调云存储 api 上传照片
                await cloud.storage().upload({
                  localPath: result.photoUris[0], //本地路径
                  cloudPath: cloudpath, //云路径
                  onUploadProgress: event => { //上传过程，回调函数，检测上传进度，可选
                    const percent = Math.floor(100 * event.loaded / event.total)
                    this.uploadingText = `${percent}%`
                  }
                })
                hilog.info(0, 'Upload', 'Upload Success')
                // 3. 获取上传照片的网络地址
                const url = await cloud.storage().getDownloadURL(cloudpath)
                this.photoUrl = url //`${url}&ts=${new Date().getTime()}`
                this.uploading = false
                hilog.info(0, 'Upload', `url: ${url}`)
              } catch (e) {
                hilog.error(0, 'Upload', JSON.stringify(e))
              }
            })
          if (this.uploading) {
            // 显示上传进度
            Text(this.uploadingText)
              .width(70)
              .height(70)
              .borderRadius(70)
              .fontColor('white')
              .backgroundColor('black')
              .opacity(0.6)
              .fontSize(24)
              .fontWeight(FontWeight.Bolder)
              .textAlign(TextAlign.Center)
          }
        }

        TextInput({placeholder:'请设置昵称',text:this.displayName})
          .width('50%')
          .onChange(value => {
            this.displayName = value
          })

        Button(`保存`)
          .onClick(async () => {
            try {
              await this.user.updateProfile({
                displayName: this.displayName,
                photoUrl: this.photoUrl
              })
              hilog.info(0, 'updateProfile', 'Success')
              promptAction.showToast({
                message: '保存成功',
                duration: 2000,
                bottom: 50
              })
              this.showflag=0
            } catch (e) {
              hilog.error(0, 'updateProfile', JSON.stringify(e))
              promptAction.showToast({
                message: '保存失败',
                duration: 2000,
                bottom: 50
              })
            }
          })
        Button('放弃')
          .onClick(()=>{
            this.showflag=0
          })
          .margin(10)
      }
      .width('100%')
    }
    .height('100%')
  }
}
