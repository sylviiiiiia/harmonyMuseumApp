// @ts-ignore 忽略报错
import schema from '../../resources/rawfile/schema.json'
import { Database } from '@hw-agconnect/cloud/src/main/ets/database/Database'
import router from '@ohos.router'
import cloud, { AuthUser } from '@hw-agconnect/cloud';
import hilog from '@ohos.hilog';
import { feedback } from '../models/feedback';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Feedback {
  private adviseContent :string = ''
  private  db:Database
  @StorageLink('user') user: AuthUser = null

  async aboutToAppear(){
    try {
      // 根据 schema 和 zoneName 创建数据库对象
      this.db = cloud.database({ objectTypeInfo: schema, zoneName:"test" })
    } catch (e) {
      hilog.error(0, "User Query", 'error:' + JSON.stringify(e))
    }
  }
  build() {
    Row() {
      Column({space:15}) {
        Text("请输入您的建议：")
          .fontSize(20)
        TextArea({placeholder:'在此键入......'})
          .onChange((content:string)=>{
            this.adviseContent=content
          })
          .height(150)
          .width('90%')
        Button('提交')
          .onClick(async()=>{
            try{
              const adv=new feedback()
              //adv.setId('1')
              adv.setAdvise(this.adviseContent)
              adv.setUid(this.user?.getUid())
              await this.db.collection(feedback).upsert(adv)
              hilog.info(0, 'feedback Update', 'Success')
              promptAction.showToast({
                message: '提交成功',
                duration: 2000,
                bottom: 50
              })
              router.back()
            }catch (e) {
              hilog.error(0, 'feedback Update', JSON.stringify(e))
            }
          })
        Button('返回')
          .onClick(()=>{
            router.back()
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}