import router from '@ohos.router'
@Entry
@Component
struct AboutUs {
  @State message: string = 'Hello World'
  name:string[]=['Sylvia','zzp','jyy','djj','hsf','lzy']
  build() {

    Column() {
      Text('BUCT')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .margin(30)

      Text('开发人员名单：')
        .margin({bottom:20})
      ForEach(
        this.name,
        (item:string,index:number)=>{
          Row(){
            Text(item)
          }
          .margin({bottom:10})
        }
      )
      Text('(以上排名不分先后)')
        .fontSize(12)

      Text('\n')
      Image($r('app.media.icon_back'))
        .width('8%')
        .onClick(()=>{
          router.back()
        })

      Row(){
        Text('联系我们：')
          .fontSize(12)
        Text('sylvia9974@qq.com')
          .fontSize(12)
          .decoration({type:TextDecorationType.Underline})
      }
      .margin({top:320})
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)


  }
}