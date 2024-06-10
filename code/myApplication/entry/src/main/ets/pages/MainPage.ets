/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { Zones } from '../view/ZonesComponent';
import { homepage, PersonalHomepage } from '../view/personalPage'
import { BottomTabsList } from '../viewmodel/BottomTabsModel';
import cloud, { AuthUser } from '@hw-agconnect/cloud'
// @ts-ignore
import schema from '../../resources/rawfile/schema.json'
import { museum } from '../models/museum';
import Prompt from '@system.prompt';
import router from '@ohos.router';
import hilog from '@ohos.hilog';
import DatabaseHelper from '../utils/DatabaseHelper';
import axios from '@ohos/axios';
import { ZonesConstants as ZoneConst } from '../common/constants/ZonesConstants';
@Entry
@Component
struct MainPage {
  @State thing_list: museum[] = [];
  @State search_name: string = '';
  @State search_res: museum[] = [];
  @State marginBottom: number = 0;
  private changedIndex: boolean = true;
  @State aheadIndex: number = ZoneConst.HALF_COUNT;
  @StorageLink('user') user:AuthUser = null
  @State @Watch('onIndexChange') bottomTabIndex: number = 1;
  private controller: TabsController = new TabsController();
  onPageShow() {
    axios({
      method: "post",
      url: 'http://8.130.122.31:8000/artifact/getRandom/',
      data:{
        number: 12
      }
    }).then(res => {
      this.thing_list = res.data
    }).catch(e => {
      console.error(e)
    })
  }
  @Builder TabBuilder(index: number, _name: string) {
    Column() {
      Image(this.bottomTabIndex === index ? BottomTabsList[index].iconSelected : BottomTabsList[index].icon)
        .width(Const.ICON_SIZE)
        .height(Const.ICON_SIZE)
        .objectFit(ImageFit.Contain)

      Text(_name)
        .fontSize($r('app.float.bottom_font_size'))
        .opacity(Const.OPACITY)
        .fontColor(this.bottomTabIndex === index ?
        $r('app.color.bottom_tabs_font_color_selected') : $r('app.color.bottom_tabs_font_color'))
    }
    .width(Const.FULL_PERCENT)
    .height(Const.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .border({ width: { top: Const.BORDER_WIDTH }, color: $r('app.color.color_border') })
    .backgroundColor($r('app.color.bottom_tabs_background_color'))
  }

  onIndexChange() {
    this.controller.changeIndex(this.bottomTabIndex);
  }

  pageTransition() {
    PageTransitionEnter({ duration: Const.SHARED_DURATION })
      .slide(SlideEffect.Top)
    PageTransitionExit({ delay: Const.EXIT_DELAY })
      .opacity(0)
  }
  getImgCoefficients(index?: number): number {
    if (index === undefined) {return 0;}
    let coefficient = this.aheadIndex - index;
    let tempCoefficient = Math.abs(coefficient);
    if (tempCoefficient <= ZoneConst.HALF_COUNT) {return coefficient;}
    let dataLength;
    dataLength = this.thing_list.length;
    let tempOffset = dataLength - tempCoefficient;
    if (tempOffset <= ZoneConst.HALF_COUNT) {
      if (coefficient > 0) {return -tempOffset;}
      return tempOffset;
    }return 0;
  }

  getOffSetY(index?: number): number {
    if (index === undefined) {return 0;}
    let offsetIndex = this.getImgCoefficients(index);
    let tempOffset = Math.abs(offsetIndex);
    let offsetY = this.marginBottom / (tempOffset + 1);
    if (tempOffset === 1) {offsetY += -offsetIndex * ZoneConst.MAX_OFFSET_Y;}
    else if (tempOffset === ZoneConst.HALF_COUNT) {offsetY += -offsetIndex * (ZoneConst.MAX_OFFSET_Y - ZoneConst.OFFSET_COEFFICIENTS);}
    return offsetY;
  }

  startAnimation(isUp: boolean): void {
    animateTo({
      duration: Const.SWIPER_DURATION,
    }, () => {
      let dataLength
      dataLength = this.thing_list.length;
      let tempIndex = isUp ? this.aheadIndex + 1 : dataLength + this.aheadIndex - 1;
      this.aheadIndex = tempIndex % dataLength;
      this.marginBottom = 0;
    });
  }

  handlePanGesture(offsetY: number): void {
    if (Math.abs(offsetY) < ZoneConst.MAX_MOVE_OFFSET) {
      this.marginBottom = offsetY;
    } else {
      if (this.changedIndex) {
        return;
      }
      this.changedIndex = true;
      this.startAnimation(offsetY < 0);
    }
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
      Tabs({ barPosition: BarPosition.End, index: 1, controller: this.controller }) {
        // TabContent() {
        //   Column() {
        //     Text(this.user.getUid())
        //     Button('查询')
        //       .onClick(async () => {
        //         //进行查询
        //         let data = await DatabaseHelper.user_query()
        //         hilog.info(0x0000, 'query',JSON.stringify(data));
        //         Prompt.showToast({ message: JSON.stringify(data) })
        //       })
        //     Button('插入')
        //       .onClick(async () => {
        //         let nuser = new user();
        //         nuser.setUser_name("zzp")
        //         nuser.setUser_id(3)
        //         let data = await DatabaseHelper.userUpdate(nuser)
        //         Prompt.showToast({ message: JSON.stringify(data) })
        //       })
        //     Button('删除')
        //       .onClick(async () => {
        //         //进行id查询
        //         let data = await DatabaseHelper.userQueryByUid('100')
        //         let res = await DatabaseHelper.deleteUser(data[0])
        //         hilog.info(0x0000, 'delete',JSON.stringify(data));
        //         //根据查到的user列表进行删除
        //         Prompt.showToast({ message: JSON.stringify(data) })
        //       })
        //
        //
        //   }
        // }.tabBar(this.TabBuilder(0, 'Map'))

        TabContent() {
          Column() {
            Row({space:10}) {
              Text('藏品列表')
                .fontSize(24)
                .align(Alignment.Center)
                .fontColor('#cd1a1c1c')
                .margin({left:150,top:8})
              Blank()
              Image($r('app.media.refresh')).width(30)
                .margin({right:8})
                .onClick(() => {
                  axios({
                    method: "post",
                    url: 'http://8.130.122.31:8000/artifact/getRandom/',
                    data:{ number: 12 }
                  }).then(res => {this.thing_list = res.data})
                    .catch(e => {console.error(e)})
                })
            }.width('100%')
            Row() {
              Search().searchButton('搜索')
                .margin({left:10, right: 10})
                .onChange(val => {this.search_name = val})
                .onSubmit(() => {
                  router.pushUrl({
                    url:'pages/SearchPage',
                    params: {name:this.search_name}
                  },router.RouterMode.Single,err=>{if(err) console.log('路由失败' + JSON.stringify(err))})
                  // axios({
                  //   method: "post",
                  //   url: 'http://8.130.122.31:8000/artifact/search/',
                  //   data:{ prompt: this.search_name }
                  // }).then(res => {this.search_res = res.data})
                  //   .catch(e => {console.error(e)})
                })
            }
            Stack(){
              ForEach(this.thing_list, (item: museum, index?: number) => {
                Row() {
                  Image(item.imageUrl)
                    .objectFit(ImageFit.Cover)
                    .borderRadius($r('app.float.common_border_radius'))
                    .margin({ bottom: Const.SHADOW_RADIUS })
                    .shadow({
                      radius: Const.SHADOW_RADIUS,
                      color: `rgba(0,0,0,0.3)`,
                      offsetY: Const.SHADOW_RADIUS / Const.DOUBLE_NUM
                    })
                    .opacity(1 - Math.min(ZoneConst.HALF_COUNT,
                      Math.abs(this.getImgCoefficients(index))) * ZoneConst.OPACITY_COEFFICIENTS)
                    .blur(ZoneConst.OFFSET_COEFFICIENTS * Math.abs(this.getImgCoefficients(index)))
                }
                .width(index !== this.aheadIndex && this.getImgCoefficients(index) === 0
                  ? Const.SWIPER_DEFAULT_WIDTH
                  : `${ZoneConst.ITEM_WIDTH - ZoneConst.OFFSET_COEFFICIENTS * Math.abs(this.getImgCoefficients(index))}%`)
                .aspectRatio(Const.SWIPER_ASPECT_RATIO)
                .borderRadius($r('app.float.common_border_radius'))
                .offset({ x: 0, y: this.getOffSetY(index) })
                .zIndex(index !== this.aheadIndex && this.getImgCoefficients(index) === 0
                  ? 0 : ZoneConst.HALF_COUNT - Math.abs(this.getImgCoefficients(index)))
                .onClick(() => {
                  router.pushUrl({
                    url:'pages/MyIntroduction',
                    params: item
                  },router.RouterMode.Single,err=>{if(err) console.log('路由失败' + JSON.stringify(err))})
                })
              },(item: museum) => JSON.stringify(item))
            }
            .width(Const.FULL_PERCENT)
            .height(Const.FULL_PERCENT)
            .margin({ top: Const.SHADOW_RADIUS / Const.DOUBLE_NUM })
            .alignContent(Alignment.Center)
            .gesture(
              PanGesture({ direction: PanDirection.Vertical })
                .onActionStart((event: GestureEvent | undefined) => {
                  if (!event) {return;}
                  this.changedIndex = false;
                  this.handlePanGesture(event.offsetY);
                })
                .onActionUpdate((event: GestureEvent | undefined) => {
                  if (!event) {return;}
                  this.handlePanGesture(event.offsetY);
                })
                .onActionEnd(() => {
                  animateTo({
                    duration: Const.SWIPER_DURATION,
                  }, () => {this.marginBottom = 0;});
                })
            )
          }
        }.tabBar(this.TabBuilder(0, '文物展示'))

        TabContent() {
          homepage()
        }.tabBar(this.TabBuilder(1, '个人主页'))
      }
      .width(Const.FULL_PERCENT)
      .height(Const.FULL_PERCENT)
      .vertical(false)
      .scrollable(false)
      .barHeight(Const.BAR_HEIGHT)
      .onChange((index: number) => {
        this.bottomTabIndex = index;
      })
    }
    .width(Const.FULL_PERCENT)
  }
}