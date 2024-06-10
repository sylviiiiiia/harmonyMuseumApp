import cloud, { AuthUser } from '@hw-agconnect/cloud'
import { Database } from '@hw-agconnect/cloud/src/main/ets/database/Database'
// @ts-ignore
import schema from '../../resources/rawfile/schema.json'
import { userLikes } from '../models/userLikes'
import hilog from '@ohos.hilog'
import router from '@ohos.router'
import { museum } from '../models/museum'
import axios from '@ohos/axios'
@Preview
@Component
export struct searchLikes {
  private db:Database=null
  @State searchid:string=''
  private treasureList:museum=null
  @State treasureName:string=''
  @State treasureUrl:string=''

  async aboutToAppear() {
   //method1:通过Web组接口查询
    axios({
      method: "post",
      url: 'http://8.130.122.31:8000/artifact/getDetail/',
      data:{ id: (Number)(this.searchid) } //
    }).then(res => {
      this.treasureList = res.data
      this.treasureName=this.treasureList.name
      this.treasureUrl=this.treasureList.imageUrl
      hilog.info(0, 'searchTreasureById', this.treasureName)

    })
      .catch(e => {
        hilog.error(0, 'searchTreasureById', JSON.stringify(e))
      })

    //method2:在云数据库查询
    // this.db = cloud.database({
    //   zoneName: 'test',
    //   objectTypeInfo: schema
    // })
    // try{
    //   const query=this.db.collection(museum).query()
    //   if (this.searchid.length>0){
    //     query.equalTo('id',this.searchid)
    //   }
    //   const result:museum[]=await query.get() //得到museum promise
    //   hilog.info(0, 'Query', `${result.map(t=>t.name)}`)
    //   if(result.length>0){
    //     //const name:string=`${result.map(t=>t.name)}`//result[0].name
    //     this.treasureName=result[0].getName()
    //     this.treasureUrl=result[0].getImageUrl()
    //   }
    // }catch(e){
    //   hilog.error(0, 'Query', JSON.stringify(e))
    // }
   }

  build(){
    Row() {
      Text(this.searchid)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .width('33%')
      Text(this.treasureName)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .width('34%')
      Image(this.treasureUrl)
        .width('33%')
    }
  }
}