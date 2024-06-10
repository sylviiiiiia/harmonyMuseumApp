// /*
//  * Copyright (c) 2023 Huawei Device Co., Ltd.
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  *     http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
//
// import router from '@ohos.router';
// import { CommonConstants as Const} from '../common/constants/CommonConstants';
// import { splashImages } from '../viewmodel/SplashModel';
//
// @Entry
// @Component
// struct Splash {
//   private swiperController: SwiperController = new SwiperController();
//   private data:string[]  = [
//     'https://copyright.bdstatic.com/vcg/creative/cc9c744cf9f7c864889c563cbdeddce6.jpg@h_1280',
//     'https://inews.gtimg.com/om_bt/OHyQqgC_5oi4Vm0tlH49XvJzqNBHo2Zryxx5F_be5N2cIAA/1000',
//     'https://inews.gtimg.com/news_bt/OLxGAuCdJ1SwoZRdrZoqGrpBGX-BgYjWnSFuiDDoS3xQsAA/1000'
//   ]
//   @State countdown: number = Const.COUNTDOWN;
//   @State showSwiper: boolean = false;
//   private timer:number = -1;
//
//   aboutToAppear(): void {
//     // let hours = new Date().getHours();
//     // if (hours >= Const.MORNING_TIME && hours < Const.EVENING_TIME) {
//     //   this.data = splashImages.day;
//     // } else if (hours >= Const.EVENING_TIME && hours <= Const.NIGHT_TIME) {
//     //   this.data = splashImages.dusk;
//     // } else {
//     //   this.data = splashImages.night;
//     // }
//     setTimeout(() => {
//       this.showSwiper = true;
//       this.startTiming();
//     }, Const.SPLASH_DURATION);
//   }
//
//   startTiming() {
//     this.timer = setInterval(() => {
//       this.countdown--;
//       if (this.countdown === 0) {
//         this.clearTiming();
//         this.jumpToMainPage();
//       }
//     }, Const.DURATION);
//   }
//
//   clearTiming() {
//     if (this.timer !== -1) {
//       clearInterval(this.timer);
//       this.timer = -1;
//     }
//   }
//
//   jumpToMainPage() {
//     this.clearTiming();
//     router.replaceUrl({
//       url: 'pages/login'
//     });
//   }
//
//   aboutToDisappear() {
//     this.clearTiming();
//   }
//
//   build() {
//     Column() {
//       Stack() {
//         if (this.showSwiper) {
//           Swiper(this.swiperController) {
//             ForEach(this.data, (item: string) => {
//               Image(item)
//                 .width(Const.FULL_SIZE)
//                 .height(Const.FULL_SIZE)
//                 .objectFit(ImageFit.Cover)
//             })
//           }
//           .loop(true)
//           .interval(2 * Const.DURATION)
//           .duration(Const.DURATION)
//           .autoPlay(true)
//           .indicatorStyle({
//             bottom: $r('app.float.100'),
//             color: $r('app.color.swiper_dot_color')
//           })
//           .curve(Curve.Linear)
//           .onChange((index: number) => {
//             console.info(index.toString())
//           })
//
//           Text() {
//             Span($r('app.string.skip'))
//             Span(`${this.countdown}`)
//           }
//           .onClick(() => this.jumpToMainPage())
//           .fontColor(Color.White)
//           .fontSize($r('app.float.12fp'))
//           .backgroundColor($r('app.color.swiper_jump_bg_color'))
//           .width($r('app.float.63'))
//           .height($r('app.float.24'))
//           .borderRadius($r('app.float.10'))
//           .textAlign(TextAlign.Center)
//           .position({
//             x: Const.PERCENTAGE_78,
//             y: $r('app.float.35')
//           })
//         } else {
//           Image($r('app.media.ic_splash2'))
//             .width(Const.FULL_PERCENT)
//             .height(Const.FULL_PERCENT)
//           // Image($r('app.media.ic_splash'))
//           //   .width($r('app.float.192'))
//           //   .height($r('app.float.192'))
//           //   .offset({
//           //     y: `-${Const.PERCENTAGE_15}`
//           //   })
//           //   .objectFit(ImageFit.Contain)
//
//           Column() {
//             Text(Const.SPLASH_DES)
//               .fontColor(Color.White)
//               .fontSize($r('app.float.font_size_24fp'))
//               .fontWeight(FontWeight.Medium)
//
//             Text(Const.SPLASH_WELCOME)
//               .fontSize($r('app.float.font_size_16fp'))
//               .fontColor(Color.White)
//               .margin({
//                 top: $r('app.float.5')
//               })
//           }
//           .offset({
//             y: Const.PERCENTAGE_25
//           })
//         }
//       }
//     }
//     .height(Const.FULL_SIZE)
//     .width(Const.FULL_SIZE)
//   }
// }
import router from '@ohos.router';
import { CommonConstants as Const} from '../common/constants/CommonConstants';
import { splashImages } from '../viewmodel/SplashModel';

@Entry
@Component
struct Splash {
  private swiperController: SwiperController = new SwiperController();
  //private data: Resource[] = [];
  private data:string[]  = [
    'https://youimg1.c-ctrip.com/target/100ffk105isk2xvs06076.jpg',
    'https://img.zcool.cn/community/01a14f576a72d10000012e7ef96850.jpg@1280w_1l_2o_100sh.jpg',
    'https://bpic.588ku.com/back_origin_min_pic/20/11/06/839a5f34057f0a103a3acbdc5b0c5afb.jpg'
  ]
  @State countdown: number = Const.COUNTDOWN;
  @State showSwiper: boolean = false;
  private timer:number = -1;

  aboutToAppear(): void {
    let hours = new Date().getHours();
    //if (hours >= Const.MORNING_TIME && hours < Const.EVENING_TIME) {
    //  this.data = splashImages.day;
    //} else if (hours >= Const.EVENING_TIME && hours <= Const.NIGHT_TIME) {
    //  this.data = splashImages.dusk;
    //} else {
    // this.data = splashImages.night;
    //}
    setTimeout(() => {
      this.showSwiper = true;
      this.startTiming();
    }, Const.SPLASH_DURATION);
  }

  startTiming() {
    this.timer = setInterval(() => {
      this.countdown--;
      if (this.countdown === 0) {
        this.clearTiming();
        this.jumpToMainPage();
      }
    }, Const.DURATION);
  }

  clearTiming() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  jumpToMainPage() {
    this.clearTiming();
    router.replaceUrl({
      url: 'pages/login'
    });
  }

  aboutToDisappear() {
    this.clearTiming();
  }

  build() {
    Column() {
      Stack() {
        if (this.showSwiper) {
          Swiper(this.swiperController) {
            ForEach(this.data, (string: Resource) => {
              Image(string)
                .width(Const.FULL_SIZE)
                .height(Const.FULL_SIZE)
                .objectFit(ImageFit.Cover)
            })
          }
          .loop(true)
          .interval(2 * Const.DURATION)
          .duration(Const.DURATION)
          .autoPlay(true)
          .indicatorStyle({
            bottom: $r('app.float.100'),
            color: $r('app.color.swiper_dot_color')
          })
          .curve(Curve.Linear)
          .onChange((index: number) => {
            console.info(index.toString())
          })

          Text() {
            Span($r('app.string.skip'))
            Span(`${this.countdown}`)
          }
          .onClick(() => this.jumpToMainPage())
          .fontColor(Color.White)
          .fontSize($r('app.float.12fp'))
          .backgroundColor($r('app.color.swiper_jump_bg_color'))
          .width($r('app.float.63'))
          .height($r('app.float.24'))
          .borderRadius($r('app.float.10'))
          .textAlign(TextAlign.Center)
          .position({
            x: Const.PERCENTAGE_78,
            y: $r('app.float.35')
          })
        } else {
          Image($r('app.media.ic_splash2'))
            .width(Const.FULL_PERCENT)
            .height(Const.FULL_PERCENT)
          // Image($r('app.media.ic_splash'))
          //   .width($r('app.float.192'))
          //   .height($r('app.float.192'))
          //   .offset({
          //     y: `-${Const.PERCENTAGE_15}`
          //   })
          //   .objectFit(ImageFit.Contain)

          Column() {
            Text(Const.SPLASH_DES)
              .fontColor(Color.White)
              .fontSize($r('app.float.font_size_24fp'))
              .fontWeight(FontWeight.Medium)

            Text(Const.SPLASH_WELCOME)
              .fontSize($r('app.float.font_size_16fp'))
              .fontColor(Color.White)
              .margin({
                top: $r('app.float.5')
              })
          }
          .offset({
            y: Const.PERCENTAGE_25
          })
        }
      }
    }
    .height(Const.FULL_SIZE)
    .width(Const.FULL_SIZE)
  }
}