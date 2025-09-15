import { router } from "@kit.ArkUI"

interface Type1{
  contents:string
}
@Entry
@Component
export struct Xuanzediqu {
  @State message: string = 'Hello World'
  @State area: string = ""
  @State showConfirmButton: boolean = false
  @State selectedCity: string = ""
  @State showDialog: boolean = false

  datas: Type1[] = [
    {contents: '北京'},
    {contents: '上海'},
    {contents: '广州'},
    {contents: '深圳'},
    {contents: '重庆'},
    {contents: '吐鲁番'},
    {contents: '苏州'}
  ]

  @Builder
  hotItems(data: Type1) {
    Button(data.contents)
      .height(35)
      .fontColor(this.selectedCity === data.contents ? '#FFFFFF' : '#333333')
      .backgroundColor(this.selectedCity === data.contents ? Color.Blue : Color.White)
      .borderColor(this.selectedCity === data.contents ? Color.Blue : '#bfbfbf')
      .borderWidth(1)
      .borderRadius(12)
      .onClick(() => {
        this.selectedCity = data.contents
        this.showConfirmButton = true
      })
  }

  @Builder
  TipDialogContent() {
    Column() {
      Text('温馨提示')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 15, bottom: 20 })
      Image($r('app.media.WeatherLogo'))
        .height(50)
        .width(50)
        .margin({ bottom: 20 })
      Text(`确认选择: ${this.selectedCity}？`)
        .fontSize(18)
        .margin({ bottom: 30 })
      Row() {
        Button('取消')
          .width('45%')
          .height(40)
          .backgroundColor(Color.White)
          .fontColor(Color.Blue)
          .margin({left:10,right:10})
          .onClick(() => {
            this.showDialog = false
          })
        Button('确定')
          .width('45%')
          .height(40)
          .backgroundColor(Color.White)
          .fontColor(Color.Blue)
          .margin({left:10,right:10})
          .onClick(() => {
            this.showDialog = false
            this.area = this.selectedCity
            this.message = `已选择: ${this.selectedCity}`
            // 跳转到WeatherYuBaoPage并传递选中的城市参数
            router.pushUrl({ 
              url: 'pages/WeatherYuBaoPage',
              params: {
                selectedCity: this.selectedCity
              }
            });
          })
      }.width('100%')
      .margin({ bottom: 15 })
    }.width('90%')
    .linearGradient({//渐变
      direction:GradientDirection.RightTop,
      colors: [[0xE5FAF9, 0], [0xF8F6F5, 0.5]]
    })
    .zIndex(2)
    //.height(150)
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    //使用Stack作为根容器，允许叠加弹窗
    Stack() {
      // 主要内容区域
      Column() {
        // 上部区域 - 选择地区
        Column() {
          Row() {
            Image($r('app.media.location1'))
              .height(35)
              .width(35)
              .margin({ right: 10 })
            Text('选择地区')
              .fontSize(24)
              .fontWeight(800)
          }.width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 70, bottom: 30 })

          // 搜索框
          Stack({ alignContent: Alignment.Center }) {
            Row() {
              // 背景框
              Column() {
                // 空内容作为背景
              }
              .width('85%')
              .height(40)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .padding({ left: 30, right: 10 })
            }

            // 输入框
            Search({
              placeholder: "搜索城市或地区...",
            })
              .placeholderFont({ size: 20 })
              .placeholderColor('#bfbfbf')
              .fontColor('#000000')
              .borderRadius(12)
              .backgroundColor(Color.Transparent)
              .padding({ left: 70, right: 5 })
              .width('100%')
            //
            // // 搜索图标
            // Image($r('app.media.graysousuo'))
            //   .height(18)
            //   .width(18)
            //   .position({ x: 50, y: 11 })
            //   .zIndex(1)
          }
        }
        .width('100%')
        .height('30%')


        // 当前位置
        Column() {
          Row() {
            Image($r('app.media.location1'))
              .height(35)
              .width(35)
              .margin({ right: 10 })
            Text('常看位置')
              .fontSize(20)
              .fontWeight(600)
          }.width('100%')
          .padding(10)
          .justifyContent(FlexAlign.Start)

          Button('历史常看位置')
            .borderColor(Color.Blue)
            .borderWidth(1)
            .backgroundColor('#F0F9FF')
            .fontColor(Color.Blue)
            .fontSize(18)
            .padding(10)
            .width('90%')
            .margin({ bottom: 10 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/WeatherPage' });
            })
        }
        .width('90%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 10 })
        // 当前位置
        Column() {
          Row() {
            Image($r('app.media.location1'))
              .height(35)
              .width(35)
              .margin({ right: 10 })
            Text('当前位置')
              .fontSize(20)
              .fontWeight(600)
          }.width('100%')
          .padding(10)
          .justifyContent(FlexAlign.Start)

          Button('获取当前位置')
            .borderColor(Color.Blue)
            .borderWidth(1)
            .backgroundColor('#F0F9FF')
            .fontColor(Color.Blue)
            .fontSize(18)
            .padding(10)
            .width('90%')
            .margin({ bottom: 10 })
        }
        .width('90%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 10 })

        // 热门城市
        Column() {
          Row() {
            Image($r('app.media.fire'))
              .height(20)
              .width(20)
              .margin({ right: 10 })
            Text('热门城市')
              .fontSize(20)
              .fontWeight(600)
          }.width('100%')
          .padding(10)
          .borderRadius(12)
          .justifyContent(FlexAlign.Start)

          Scroll() {
            Row() {
              ForEach(this.datas, (item: Type1) => {
                this.hotItems(item)
                if (item !== this.datas[this.datas.length - 1]) {
                  Blank().width(10)
                }
              })
            }
            .width('200%')
          }
          .padding({ bottom: 10 })
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('90%')
        }
        .backgroundColor(Color.White)
        .width('90%')
        .borderRadius(12)

        // 确认按钮 - 条件渲染
        if (this.showConfirmButton) {
          Column() {
            Button(`确认选择 ${this.selectedCity}`)
              .width('90%')
              .height(50)
              .backgroundColor(Color.Blue)
              .fontColor(Color.White)
              .fontSize(18)
              .margin({ top: 30 })
              .onClick(() => {
                this.showDialog = true
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      //.backgroundColor('#ECECEC')
      .linearGradient({
        angle: 45,
        colors: [ ["#E9F9F8", 0],["#F7F6F4", 0.5]]
      })

      //  弹窗作为Stack的子节点
      if (this.showDialog) {
        // 半透明遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
          .opacity(0.5)
          .zIndex(1)

        // 弹窗内容
        this.TipDialogContent()
        // .position({ x: '50%', y: '40%' })
        // .transform({ translateX: '-50%', translateY: '-50%' })
        //.zIndex(2)
      }
    }
    .width('100%')
    .height('100%')
  }
}
