import { router } from '@kit.ArkUI';
import prompt from '@system.prompt';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';

// 根据天气类型获取背景图片
function getWeatherBackground(weatherType: string): Resource {
  switch (weatherType) {
    case '大雨':
      return $r('app.media.rainy');
    case '小雨':
      return $r('app.media.rainy');
    case '雨':
      return $r('app.media.rainy');
    case '多云':
      return $r('app.media.rainy');
    case '阴天':
      return $r('app.media.cloudy');
    case '晴':
      return $r('app.media.cloudy');
    case '晴天':
      return $r('app.media.cloudy');
    default:
      return $r('app.media.cloudy');
  }
}

// 城市天气数据接口 - 添加is_active字段
interface CityWeather {
  id: number;
  cityName: string;
  weather: string;
  temperature: string;
  value: number; // 右侧显示的数字
  isActive: number; // 是否激活，1表示激活，0表示未激活
}

// API响应接口
interface ApiResponse {
  code: number;
  message: string;
  data?: CityWeather[];
}

@Entry
@Component
struct WeatherPage {
  // 搜索关键字
  @State searchText: string = '';
  // 城市天气数据 - 初始为空数组
  @State cities: CityWeather[] = [];
  // 加载状态
  @State isLoading: boolean = false;
  // 后端服务器地址
  private serverUrl: string = 'http://192.168.250.242:5000';

  aboutToAppear() {
    // 页面加载时获取城市列表
    this.loadCities();
  }

  // 从数据库加载城市列表 - 只获取激活的城市
  async loadCities() {
    this.isLoading = true;
    try {
      let httpRequest = http.createHttp();
      let response = await httpRequest.request(
        this.serverUrl + "/api/cities/active",
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
          console.info('获取激活城市列表成功');
          this.cities = result.data;
        } else {
          console.error('获取城市列表失败:', result.message);
          promptAction.showToast({ message: `获取城市列表失败: ${result.message}`, duration: 2000 });
        }
      } else {
        console.error('获取城市列表请求失败:', response.responseCode);
        promptAction.showToast({ message: `获取城市列表请求失败: ${response.responseCode}`, duration: 2000 });
      }
    } catch (error) {
      console.error('获取城市列表失败:', error);
      promptAction.showToast({ message: `获取城市列表失败: ${error}`, duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }

  // 激活城市（将is_active从0改为1）
  async addCity() {
    if (this.searchText.trim() === '') {
      promptAction.showToast({ message: '请输入城市名称', duration: 2000 });
      return;
    }

    this.isLoading = true;
    try {
      let httpRequest = http.createHttp();
      let response = await httpRequest.request(
        this.serverUrl + "/api/cities/activate",
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({
            cityName: this.searchText.trim()
          })
        }
      );

      if (response.responseCode === 200) {
        let result: ApiResponse = JSON.parse(response.result.toString());
        if (result.code === 0) {
          console.info('激活城市成功');
          promptAction.showToast({ message: '激活城市成功', duration: 2000 });
          // 清空输入框
          this.searchText = '';
          // 重新加载城市列表
          this.loadCities();
        } else {
          console.error('激活城市失败:', result.message);
          promptAction.showToast({ message: `激活城市失败: ${result.message}`, duration: 2000 });
        }
      } else if (response.responseCode === 409) {
        console.error('激活城市失败: 城市已经是激活状态');
        promptAction.showToast({ message: '城市已经是激活状态，无需重复激活', duration: 2000 });
      } else if (response.responseCode === 404) {
        console.error('激活城市失败: 城市不存在');
        promptAction.showToast({ message: '城市不存在，请检查城市名称', duration: 2000 });
      } else {
        console.error('激活城市请求失败:', response.responseCode);
        promptAction.showToast({ message: `激活城市请求失败: ${response.responseCode}`, duration: 2000 });
      }
    } catch (error) {
      console.error('激活城市失败:', error);
      promptAction.showToast({ message: `激活城市失败: ${error}`, duration: 2000 });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.blackaback')) // 使用黑色返回箭头图标
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => router.back())

        Text('城市管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({right:31})
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      // .alignItems(VerticalAlign.Center)

      // 搜索区域
      Row({ space: 10 }) {
        Image($r('app.media.graysousuo'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
        TextInput({ placeholder: '请输入城市名称', text: this.searchText })
          .placeholderColor('#999999')
          .placeholderFont({ size: 16 })
          .caretColor('#07C160')
          .fontColor('#333333')
          .fontSize(16)
          .height(40)
          .layoutWeight(1)
          .backgroundColor('#FFFFFF')
          .padding(8)
          .onChange((value: string) => {
            this.searchText = value;
          })

        Button(this.isLoading ? '添加中...' : '添加')
          .width(80)
          .height(40)
          .fontSize(16)
          .fontColor('#067FD7')
          .backgroundColor('#FFFFFF')
          .enabled(!this.isLoading)
          .onClick(() => this.addCity())
      }
      .width('96%')
      .border({ width: 1, color: '#E0E0E0' })
      .borderRadius(10)
      .backgroundColor('#FFFFFF')
      .margin({ top: 16, bottom: 13 })
      .alignItems(VerticalAlign.Center)

      // 城市天气列表 - 只显示激活的城市
      List({ space: 12 }) {
        ForEach(this.cities.filter(city => city.isActive === 1), (city: CityWeather) => {
          ListItem() {
            // 城市天气卡片 - 添加天气背景图片
            Stack() {
              // 根据天气类型显示背景图片
              Image(getWeatherBackground(city.weather))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(8)

              // 半透明遮罩，使文字更清晰
              Row()
                .width('100%')
                .height('100%')
                .backgroundColor('rgba(255, 255, 255, 0.3)')
                .borderRadius(8)

              // 内容层
              Row() {
                Row() {
                  Column({ space: 20}) {
                    Text(city.cityName)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF') // 白色文字
                      .padding({left:10})
                      .textAlign( TextAlign.Start )
                      .width('100%')

                    Row() {
                      Text(city.weather)
                        .fontSize(16)
                        .fontColor('#FFFFFF') // 白色文字
                        .padding({left:7})
                        // .textAlign( TextAlign.Start )


                      Text(city.temperature)
                        .fontSize(16)
                        .fontColor('#FFFFFF') // 白色文字
                        .margin({ left: 10})
                    }
                    .width('100%')
                    .padding({left:4})
                  }

                }
                .width('100%')
                .layoutWeight(1)

                // 右侧数字
                Text(city.value.toString())
                  .fontSize(38)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  // .width(40)
                  .textAlign(TextAlign.Center)
                  .margin({ right: 16 })
              }
              .padding({ top: 16, bottom: 16, left: 16, right: 16 })
            }
            .width('100%')
            .height(110) // 固定的卡片高度
            .borderRadius(8)
            .shadow({ radius: 3, color: '#00000020', offsetX: 2, offsetY: 2 })
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/CityWeatherDetailPage',
              params: { cityName: city.cityName }
            });
          })
        }, (city:CityWeather) => city.id.toString())
      }
      .layoutWeight(1) // 占据剩余空间
      .width('98%')
      .divider({ strokeWidth: 0 })
      .padding(8)
      .margin({ bottom: 16 })
    }
    .height('100%')
    .width('100%')
    .linearGradient({//渐变背景
      direction:GradientDirection.RightTop,
      colors: [[0xE5FAF9, 0], [0xF8F6F5, 0.5]]
    })
  }
}