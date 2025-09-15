import router from "@ohos.router";
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';

// 定义三小时预报数据结构
interface HourlyData {
  time: string;
  temp: number;
}

// 定义生活指数数据结构
interface LivingIndex {
  name: string;
  value: string;
  tag: string;
  tagColor: string;
}

// 定义未来七天预报数据结构
interface DailyForecast {
  day: string;
  weather: string;
  icon: Resource;
  high: number;
  low: number;
}

// 城市数据结构
interface City {
  name: string;
}

// 七天预报数据接口（用于API数据）
interface DailyForecastData {
  day: string;
  weather: string;
  high: number;
  low: number;
}

// API响应接口
interface ApiResponse {
  code: number;
  message: string;
  data?: CityWeatherData;
}

// 城市天气数据接口
interface CityWeatherData {
  cityName: string;
  cityDescription: string;
  currentTemp: number;
  feelsLike: number;
  windDirection: string;
  windLevel: number;
  weatherDesc: string;
  hourlyData: HourlyData[];
  livingIndex: LivingIndex[];
  dailyForecast: DailyForecastData[];
}

@Entry
@Component
struct WeatherPage {
  // 从路由参数获取选中的城市，如果没有则默认为北京
  @State city: string = this.getSelectedCityFromParams();
  @State currentTemp: number = 24;
  @State feelsLike: number = 26;
  @State windDirection: string = "西南风";
  @State windLevel: number = 2;
  @State weatherDesc: string = "晴";
  @State showCitySelectDialog: boolean = false; // 城市选择弹窗控制
  @State isLoading: boolean = false; // 加载状态

  // 后端服务器地址
  private serverUrl: string = 'http://192.168.32.1:5000';

  @State cityList: City[] = [ // 城市列表 - 更新为数据库中的城市
    { name: "北京" },
    { name: "上海" },
    { name: "广州" },
    { name: "深圳" },
    { name: "重庆" },
    { name: "吐鲁番" },
    { name: "苏州" }
  ];

  @State hourlyData: HourlyData[] = [
    { time: "18:00", temp: 29 },
    { time: "21:00", temp: 28 },
    { time: "00:00", temp: 26 },
    { time: "03:00", temp: 25 },
    { time: "06:00", temp: 24 },
    { time: "09:00", temp: 26 }
  ];

  @State livingIndex: LivingIndex[] = [
    { name: "感冒指数", value: "可能", tag: "低风险", tagColor: "#3888FF" },
    { name: "洗车指数", value: "较适宜", tag: "适宜", tagColor: "#27C281" },
    { name: "穿衣指数", value: "短袖", tag: "舒适", tagColor: "#27C281" },
    { name: "紫外线指数", value: "中等", tag: "中等", tagColor: "#FF9C31" },
    { name: "运动指数", value: "不适宜", tag: "注意", tagColor: "#FF9C31" },
    { name: "化妆指数", value: "保湿", tag: "适宜", tagColor: "#27C281" }
  ];

  @State dailyForecast: DailyForecast[] = [
    { day: "今天", weather: "晴", icon: $r('app.media.sun'), high: 32, low: 24 },
    { day: "周六", weather: "多云", icon: $r('app.media.cloudyweather'), high: 30, low: 23 },
    { day: "周日", weather: "小雨", icon: $r('app.media.rain'), high: 28, low: 22 },
    { day: "周一", weather: "小雨", icon: $r('app.media.rain'), high: 27, low: 21 },
    { day: "周二", weather: "阴", icon: $r('app.media.cloudyweather'), high: 29, low: 22 },
    { day: "周三", weather: "晴", icon: $r('app.media.sun'), high: 31, low: 23 },
    { day: "周四", weather: "晴", icon: $r('app.media.sun'), high: 33, low: 24 }
  ];

  // 安全地获取路由参数中的城市
  private getSelectedCityFromParams(): string {
    try {
      const params = router.getParams();
      if (params && typeof params === 'object') {
        const paramsObj = params as Record<string, string>;
        if (paramsObj.selectedCity && typeof paramsObj.selectedCity === 'string' && paramsObj.selectedCity.trim() !== '') {
          return paramsObj.selectedCity;
        }
      }
    } catch (error) {
      console.warn('获取路由参数失败:', error);
    }
    return "北京"; // 默认城市
  }

  aboutToAppear() {
    // 页面加载时获取城市天气数据（优先使用传递的城市参数）
    console.info(`WeatherYuBaoPage加载，选中城市: ${this.city}`);
    this.loadCityWeatherData(this.city);
  }

  // 从数据库加载城市天气数据
  async loadCityWeatherData(cityName: string) {
    this.isLoading = true;
    try {
      let httpRequest = http.createHttp();
      let response = await httpRequest.request(
        this.serverUrl + `/api/hotcities/${cityName}`,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );

      if (response.responseCode === 200) {
        let result: ApiResponse = JSON.parse(response.result.toString());
        if (result.code === 0 && result.data) {
          console.info('获取城市天气数据成功');
          this.updateWeatherDataFromAPI(result.data);
        } else {
          console.error('获取城市天气数据失败:', result.message);
          promptAction.showToast({ message: `获取天气数据失败: ${result.message}`, duration: 2000 });
        }
      } else {
        console.error('获取城市天气数据请求失败:', response.responseCode);
        promptAction.showToast({ message: `获取天气数据请求失败: ${response.responseCode}`, duration: 2000 });
      }
    } catch (error) {
      console.error('获取城市天气数据失败:', error);
      promptAction.showToast({ message: `获取天气数据失败: ${error}`, duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }

  // 根据API数据更新天气信息
  updateWeatherDataFromAPI(data: CityWeatherData) {
    this.city = data.cityName;
    this.currentTemp = data.currentTemp;
    this.feelsLike = data.feelsLike;
    this.windDirection = data.windDirection;
    this.windLevel = data.windLevel;
    this.weatherDesc = data.weatherDesc;

    // 更新三小时天气预报
    this.hourlyData = data.hourlyData;

    // 更新生活指数
    this.livingIndex = data.livingIndex;

    // 更新七天预报（需要添加图标）
    this.dailyForecast = data.dailyForecast.map((item: DailyForecastData): DailyForecast => ({
      day: item.day,
      weather: item.weather,
      icon: this.getWeatherIcon(item.weather),
      high: item.high,
      low: item.low
    }));
  }

  // 根据天气类型获取图标
  getWeatherIcon(weather: string): Resource {
    switch (weather) {
      case '晴':
        return $r('app.media.sun');
      case '多云':
        return $r('app.media.cloudyweather');
      case '阴':
        return $r('app.media.cloudy2');
      case '小雨':
      case '大雨':
      case '雷阵雨':
        return $r('app.media.rain');
      default:
        return $r('app.media.sun');
    }
  }

  // 切换城市并更新天气数据
  changeCity(newCity: string) {
    this.city = newCity;
    this.loadCityWeatherData(newCity); // 从数据库加载天气数据
    this.showCitySelectDialog = false;
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          // 顶部导航栏（含城市切换按钮）
          Stack({ alignContent: Alignment.Start }) {
            Row() {
              Text(this.city)
                .fontColor(Color.Black)
                .flexGrow(1)
                .textAlign(TextAlign.Center)
                .fontWeight(FontWeight.Bold)
                .fontSize(20)

              // 城市切换按钮
              Button() {
                Image($r("app.media.location1")) // 需替换为实际图标资源
                  .width(24)
                  .height(24)
              }
              .type(ButtonType.Circle)
              .backgroundColor("#ffffff")
              .margin({ right: 16 })
              .onClick(() => {
                this.showCitySelectDialog = true;
              })
            }
            .width("100%")
            .height(56)
            .backgroundColor("#ffffff")

            // 返回按钮
            Row() {
              Image($r("app.media.blackaback"))
                .height(24)
                .margin({ left: 16,bottom:16 })
              Text("返回")
                .fontColor(Color.White)
                .fontSize(16)
            }
            .align(Alignment.Start)
            .margin({ top: 16 })
          }
          .width("100%")
          .margin({ bottom: 8 })

          Row() {
            // 左侧区域 - 温度信息
            Column() {
              // 顶部温度显示区
              Row() {
                Text(this.currentTemp.toString())
                  .fontSize(64)
                  .fontColor("#333")
                  .fontWeight(FontWeight.Bold)

                Text("°")
                  .fontSize(40)
                  .fontColor("#333")
                  .margin({ bottom: 10 })
              }
              .alignItems(VerticalAlign.Bottom)

              // 天气描述
              Text(this.weatherDesc)
                .fontSize(20)
                .fontColor("#333")
                .margin({ top: 16, bottom: 8 })
                .fontWeight(FontWeight.Medium)

              // 体感温度显示
              Column() {
                Text("体感温度")
                  .fontSize(14)
                  .fontColor("#666")
                  .fontWeight(FontWeight.Normal)
                  .margin({ left:15})

                Text(`${this.feelsLike}°`)
                  .fontSize(16)
                  .fontColor("#49D590")
                  .fontWeight(FontWeight.Medium)
                  .margin({ left:11})
              }
              // .alignItems(HorizontalAlign.Start)
            }
            .layoutWeight(1) // 占满左侧空间

            // 中间分隔线
            Divider()
              .vertical(true)
              .height(70)
              .margin({ left: 16, right: 16 })
              .strokeWidth(0.5)
              .color("#EEEEEE")

            // 右侧区域 - 风向风力信息
            Column() {
              // 天气图标
              // 根据天气情况显示不同图标
              if (this.weatherDesc === '晴') {
                Image($r('app.media.sun'))
                  .width(80)
                  .height(80)
                  .margin({ bottom: 10 })
              } else if (this.weatherDesc === '多云') {
                Image($r('app.media.cloudyweather'))
                  .width(80)
                  .height(80)
                  .margin({ bottom: 10 })
              } else if (this.weatherDesc === '雨' || this.weatherDesc === '小雨' || this.weatherDesc === '大雨') {
                Image($r('app.media.rainy'))
                  .width(80)
                  .height(80)
                  .margin({ bottom: 10 })
              } else {
                // 默认天气图标
                Image($r('app.media.sun'))
                  .width(80)
                  .height(80)
                  .margin({ bottom: 10 })
              }

              // 风向风力信息
              Column() {
                Text("风向风力")
                  .fontSize(14)
                  .fontColor("#666")
                  .fontWeight(FontWeight.Normal)

                Row({ space: 2 }) {
                  Text(this.windDirection)
                    .fontSize(16)
                    .fontColor("#49D590")
                    .fontWeight(FontWeight.Medium)

                  Text(`${this.windLevel}级`)
                    .fontSize(16)
                    .fontColor("#333")
                    .fontWeight(FontWeight.Medium)
                }
              }
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width("100%")
          .backgroundColor(Color.White)
          .padding({ top: 16, bottom: 16, left: 24, right: 24 })
          .borderRadius(12)
          .margin({ bottom: 8 })

          // 三小时预报
          Column() {
            Text("三小时预报")
              .fontSize(18)
              .fontColor("#333")
              .margin({ bottom: 16, left: 8 })
              .fontWeight(FontWeight.Medium)

            Scroll() {
              Row() {
                // 当前时间
                Column({ space: 4 }) {
                  Text("现在")
                    .fontSize(16)
                    .fontColor("#666")
                  Text(`${this.currentTemp}°`)
                    .fontSize(20)
                    .fontColor("#333")
                    .fontWeight(FontWeight.Medium)
                }
                .padding(12)
                .backgroundColor("#F5F8FF")
                .borderRadius(8)
                .margin({ right: 8 })

                // 预报数据
                ForEach(this.hourlyData, (item: HourlyData) => {
                  Column({ space: 4 }) {
                    Text(item.time)
                      .fontSize(16)
                      .fontColor("#666")
                    Text(`${item.temp}°`)
                      .fontSize(20)
                      .fontColor("#333")
                      .fontWeight(FontWeight.Medium)
                  }
                  .padding(12)
                  .backgroundColor("#F5F8FF")
                  .borderRadius(8)
                  .margin({ right: 8 })
                })
              }
              .padding({ left: 8, right: 8 })
            }
            .scrollBar(BarState.Off)
            .scrollable(ScrollDirection.Horizontal)
          }
          .width("100%")
          .backgroundColor(Color.Transparent)
          .padding({ top: 16, bottom: 16 })
          .borderRadius(12)
          .margin({ bottom: 8 })

          // 生活指数
          Column() {
            Text("生活指数")
              .fontSize(18)
              .fontColor("#333")
              .margin({ bottom: 16, left: 8 })
              .fontWeight(FontWeight.Medium)

            Grid() {
              ForEach(this.livingIndex, (item: LivingIndex) => {
                GridItem() {
                  Column({ space: 8 }) {
                    Text(item.name)
                      .fontSize(16)
                      .fontColor("#666")
                    Text(item.value)
                      .fontSize(18)
                      .fontColor("#333")
                      .fontWeight(FontWeight.Medium)
                    Text(item.tag)
                      .fontSize(14)
                      .fontColor(item.tagColor)
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .borderRadius(12)
                  }
                  .padding(12)
                  .backgroundColor("#F8F8F8")
                  .borderRadius(8)
                  .width('100%')
                }

              })
            }
            .columnsTemplate("1fr 1fr")
            .columnsGap(12)
            .rowsGap(12)
            .padding({ left: 8, right: 8 })
          }
          .width("100%")
          .backgroundColor(Color.White)
          .padding({ top: 16, bottom: 16 })
          .borderRadius(12)
          .margin({ bottom: 8 })

          // 未来七天预报
          Column() {
            Text("未来七天预报")
              .fontSize(18)
              .fontColor("#333")
              .margin({ bottom: 16, left: 8 })
              .fontWeight(FontWeight.Medium)

            ForEach(this.dailyForecast, (item: DailyForecast) => {
              Row() {
                Text(item.day)
                  .fontSize(16)
                  .fontColor("#333")
                  .layoutWeight(1)

                Image(item.icon)
                  .height(28)
                  .margin({ right: 8 })

                Text(item.weather)
                  .fontSize(16)
                  .fontColor("#666")
                  .margin({ right: 16 })
                  .width(60)

                Row() {
                  Text(`${item.high}°`)
                    .fontSize(18)
                    .fontColor("#333")
                    .fontWeight(FontWeight.Medium)
                  Text(`${item.low}°`)
                    .fontSize(18)
                    .fontColor("#999")
                    .margin({ left: 16 })
                }
                .width(100)
                .justifyContent(FlexAlign.End)
              }
              .padding({ top: 12, bottom: 12, left: 8, right: 8 })
              .border({ width: { bottom: 1 }, color: "#EEEEEE" })
              .alignItems(VerticalAlign.Center)
            })
          }
          .width("100%")
          .backgroundColor(Color.Transparent)
          .padding({ top: 16, bottom: 16 })
          .borderRadius(12)
          .margin({ bottom: 16 })
        }
        .width("100%")
        .padding(12)
      }
      .width("100%")
      .height("100%")
      .backgroundColor("#ECECEC")

      // 城市选择弹窗（放在Stack容器内，解决根节点唯一问题）
      if (this.showCitySelectDialog) {
        Stack() {
          // 半透明背景
          Rect()
            .width('100%')
            .height('100%')
            .fill(Color.Black)
            .opacity(0.5)
            .onClick(() => {
              this.showCitySelectDialog = false;
            })

          // 弹窗内容
          Column() {
            Text("选择城市")
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor("#333")
              .margin({ top: 16, bottom: 16 })
              .width('100%')
              .textAlign(TextAlign.Center)

            Scroll() {
              Column({ space: 1 }) {
                ForEach(this.cityList, (item: City) => {
                  Text(item.name)
                    .fontSize(16)
                    .fontColor("#333")
                    .padding({ top: 14, bottom: 14 })
                    .width('100%')
                    .textAlign(TextAlign.Center)
                    .backgroundColor(Color.White)
                    .onClick(() => {
                      this.changeCity(item.name);
                    })
                })
              }
            }
            .flexGrow(1)

            // 取消按钮
            Button("取消")
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontColor("#333")
              .backgroundColor("#F5F5F5")
              .margin({ top: 12, bottom: 16 })
              .onClick(() => {
                this.showCitySelectDialog = false;
              })
          }
          .width('80%')
          .height('60%')
          .linearGradient({//渐变
            direction:GradientDirection.RightTop,
            colors: [ ["#E9F9F8", 0],["#F7F6F4", 0.5]]
          })
          .borderRadius(16)
          .position({ x: '10%', y: '20%' })
        }
      }

    }
    .linearGradient({
      angle: 45,
      colors: [ ["#E9F9F8", 0],["#F7F6F4", 0.5]]
    })
  }


}