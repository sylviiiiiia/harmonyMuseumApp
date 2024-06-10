import cloud, { VerifyCodeAction } from '@hw-agconnect/cloud'
import hilog from '@ohos.hilog'
import router from '@ohos.router'

@Entry
@Component
struct MyLoginCustom {
  @State countDown: number = 10//倒计时
  intervalId: number = 0
  @State verifyCodeButtonText: string = '获取验证码'
  @State verifyCodeButtonEnable: boolean = true
  @State phoneNumber: string = ''
  @State verifyCode: string = ''
  private mainPage = `pages/MainPage`

  //在页面渲染之前，判断是否用户已登录，如果已经登录就不直接转到主页
  async aboutToAppear() {
    try {
      const user = await cloud.auth().getCurrentUser()
      hilog.error(0x0000, 'Login', JSON.stringify(user))
      if (user != null) {
        AppStorage.SetOrCreate('user', user) // 存
        router.replaceUrl({ url: this.mainPage })
      }
    } catch (e) {
      hilog.error(0x0000, 'Login', JSON.stringify(e))
    }
  }

  //验证码倒计时
  waiting() {
    this.verifyCodeButtonText = `${this.countDown} s`
    this.verifyCodeButtonEnable = false
    this.intervalId = setInterval(() => {
      this.verifyCodeButtonText = `${this.countDown} s`
      this.countDown--
      if (this.countDown < 0) {
        clearInterval(this.intervalId)
        this.countDown = 10
        this.intervalId = 0
        this.verifyCodeButtonText = '获取验证码'
        this.verifyCodeButtonEnable = true
        return
      }
      this.countDown--
    }, 1000)
  }

  //用户登录，手机+验证码登录
  async login() {
    try {
      const result = await cloud.auth().signIn({
        credentialInfo: {
          kind: 'phone',
          countryCode: '86',
          phoneNumber: this.phoneNumber,
          verifyCode: this.verifyCode
        }
      })
      const user = result.getUser()
      AppStorage.SetOrCreate('user', user) // 存
      hilog.info(0x0000, 'Login', 'Success')
      AlertDialog.show({ title: 'yes', message: `登录成功${JSON.stringify(user)}` })
      router.replaceUrl({ url: this.mainPage })

    } catch (e) {
      hilog.error(0x0000, 'Login', JSON.stringify(e))
      AlertDialog.show({ title: '错误', message: `登录失败 ${JSON.stringify(e)}` })
    }
  }

  //发送验证码
  async sending() {
    try {
      await cloud.auth().requestVerifyCode({
        verifyCodeType: {
          kind: 'phone',
          phoneNumber: this.phoneNumber,
          countryCode: '86'
        },
        action: VerifyCodeAction.REGISTER_LOGIN,
        lang: 'zh_CN',
        sendInterval: 10
      })
      hilog.info(0x0000, 'VerifyCode', 'Success')
    } catch (e) {
      AlertDialog.show({ title: '错误', message: '验证码发送失败' })
      hilog.error(0x0000, 'VerifyCode', JSON.stringify(e))
    }
  }
  build() {
    Row() {
      Column({ space: 10 }) {
        Text('欢迎登录')
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
        Divider()
        TextInput({ placeholder: '请输入手机号' })
          .width('80%')
          .type(InputType.Number)
          .onChange(value => {
            this.phoneNumber = value
          })
        Row({ space: 10 }) {
          TextInput({ placeholder: '请输入验证码' })
            .width('55%')
            .type(InputType.Number)
            .onChange(value => {
              this.verifyCode = value
            })
          Button(this.verifyCodeButtonText)
            .enabled(this.verifyCodeButtonEnable)
            .onClick(() => {
              this.waiting()
              this.sending()
            })
        }
        .width('80%')
        .justifyContent(FlexAlign.SpaceBetween)

        Button('登录')
          .enabled(this.phoneNumber.length === 11 && this.verifyCode.length === 6)
          .onClick(async () => {
            await this.login();
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}