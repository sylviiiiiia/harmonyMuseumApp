import cloud, { AuthUser } from '@hw-agconnect/cloud'
import hilog from '@ohos.hilog'
import router from '@ohos.router'
import picker from '@ohos.file.picker'
import promptAction from '@ohos.promptAction'
@Component
export struct SetPersonalInfo  {
  @State photoUrl:string =''
  @State displayName:string =''
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
            .width(35)
            .height(35)
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
              router.back()
            } catch (e) {
              hilog.error(0, 'updateProfile', JSON.stringify(e))
              promptAction.showToast({
                message: '保存失败',
                duration: 2000,
                bottom: 50
              })
            }
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}