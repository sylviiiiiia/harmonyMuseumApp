import cloud, { AuthUser } from '@hw-agconnect/cloud'
import { Database } from '@hw-agconnect/cloud/src/main/ets/database/Database'
// @ts-ignore
import schema from '../../resources/rawfile/schema.json'
import { userLikes } from '../models/userLikes'
import hilog from '@ohos.hilog'
import router from '@ohos.router'
import { museum } from '../models/museum'
import {searchLikes} from '../view/searchLikes'
import { userReview } from '../models/userReview'
import {searchComment} from '../view/searchComment'


@Entry
@Component
struct MyComment {
  @State commentList:userReview[]=[]
  private db:Database=null
  private  dataOffset:number=0
  @State searchid:string=''
  private searchUid:string= ''
  @StorageLink('user') user: AuthUser = null
  @State treasureName:string=''
  @State treasureUrl:string=''

  aboutToAppear() {
    this.db = cloud.database({
      zoneName: 'test',
      objectTypeInfo: schema
    })
    this.searchUid=this.user?.getUid()
    this.search(this.searchUid, '', this.dataOffset) //查询全部
  }
  //用用户名或文物编号查询文物列表
  //offset偏移量，limit每页多少条记录，给一个默认值 id是文物id，uid是用户id
  async search(uid : string, id: string, offset: number, limit: number = 10) {
    try {
      const query = this.db.collection(userReview).query() //拿到database对象，选择表，query查询
      if (uid.length > 0) {
        // where uid=?
        query.equalTo("uid", uid)
      }
      if (id.length > 0) {
        // where id=?
        query.equalTo("id", id)
      }
      query.limit(limit, offset) //参数是：一页几条，每页偏移位置
      query.orderByAsc("id") //id升序
      const list: userReview[] = await query.get() //真正到云数据库去查询
      this.commentList.push(...list)
      hilog.info(0, 'Query', `${list.map(s => s.id)}`)
    } catch (e) {
      hilog.error(0, 'Query', JSON.stringify(e))
    }
  }

  build() {
    Column({space:5}){
      //1. 顶部标题
      Row(){
        Image($r('app.media.icon_back'))
          .width('5%')
          .onClick(()=>{
            router.back()
          })
        Text('我的评论')
      }
      .margin({top:15})
      .justifyContent(FlexAlign.Start)

      //2. 搜索框
      Search()
        .searchButton('筛选')
        .onChange(value => {
          this.searchid = value
        })
        .onSubmit(() => {
          this.commentList = []
          this.dataOffset = 0
          this.search(this.searchUid, this.searchid, this.dataOffset)
        })
      //3.表头
      Row() {
        Text(`文物编号`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('white')
          .textAlign(TextAlign.Center)
          .width('33%')
        Text(`文物名称`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('white')
          .textAlign(TextAlign.Center)
          .width('34%')
        Text(`我的评论`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('white')
          .textAlign(TextAlign.Center)
          .width('33%')
      }
      .width('100%')
      .height(36)
      .backgroundColor('black')

      //4.表单
      List({ space: 30 }) {
        ForEach(this.commentList, (lk: userReview) => {
          ListItem() {
            Row(){
              searchComment({searchid:lk.getId()})
              .width('66%')

              if (lk.getContent()!=''){
                Text(lk.getContent())
                  .width('33%')
              }else {
                Image(lk.getImageUrl())
                  .width('33%')
                  .onError(()=>{
                    hilog.error(0,'myComment',lk.getImageUrl())
                  })

              }
            }

          }
        })
      }
      .width('100%')
      .height('82%')
      .onReachEnd(() => { //触底时，查询第二页记录，注意，记录一起的高度要比list高度高，否则无法触底
        this.dataOffset += 10
        this.search(this.searchUid,this.searchid,this.dataOffset)
      })
    }

  }
}