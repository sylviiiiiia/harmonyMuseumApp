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
export struct searchComment {
  private db:Database=null
  @State searchid:string=''
  private treasure:museum=null
  @State treasureName:string=''

  async aboutToAppear() {
    //method1:通过Web组接口查询
    axios({
      method: "post",
      url: 'http://8.130.122.31:8000/artifact/getDetail/',
      data:{ id: (Number)(this.searchid) } //
    }).then(res => {
      this.treasure = res.data
      this.treasureName=this.treasure.name
      hilog.info(0, 'searchTreasureById', this.treasureName)

    })
      .catch(e => {
        hilog.error(0, 'searchTreasureById', JSON.stringify(e))
      })

  }

  build(){
    Row() {
      Text(this.searchid)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .width('50%')
      Text(this.treasureName)
        .fontSize(18)
        .textAlign(TextAlign.Center)
        .width('50%')
    }
  }
}