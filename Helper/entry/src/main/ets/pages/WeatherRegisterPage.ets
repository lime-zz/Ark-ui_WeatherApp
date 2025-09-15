import { router } from '@kit.ArkUI';
import { sendableColorSpaceManager } from '@kit.ArkGraphics2D';
import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';

// 定义接口响应类型
interface ApiResponse {
  code: number;
  message: string;
}

@Entry
@Component
struct Register {
  @State account: string = '';
  @State password: string = '';
  @State isPasswordVisible: boolean = false;
  @State isLoading: boolean = false;
  // 后端服务器地址
  private serverUrl: string = 'http://192.168.32.1:5000';

  build() {
    Column({space:10}) {
      Image($r("app.media.WeatherLogo"))
        .width(100)
        .height(100)
        .margin({ top: 50, bottom: 5 })
      Text('随心天气')
        .fontSize(20)
        .fontWeight(400)
        .textAlign(TextAlign.Center)
      Text('开启美好生活')
        .fontSize(16)
        .fontColor('#BDBDBD')
        .textAlign(TextAlign.Center)

      TextInput({ placeholder: "请输入用户名", text: $$this.account })
        .placeholderFont({
          size: 14,
        })
        .padding({ left: 20, right: 20 })
        .borderRadius(8)
        .backgroundColor('#eeeeee')
        .onChange((value: string) => {
          this.account = value;
        })

      // 密码输入框区域
      Row() {
        TextInput({ placeholder: "请输入用户密码", text: this.password })
          .placeholderFont({ size: 14 })
          .fontSize(14)
          .width('100%')
          .height(40)
          .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
          .onChange((value: string) => {
            this.password = value;
          })
          .layoutWeight(1)
          .padding({ left: 20 })
          .backgroundColor('transparent') // 关键：透明背景

        // // 密码显示/隐藏按钮
        // Button(this.isPasswordVisible ? '隐藏' : '显示')
        //   .fontSize(12)
        //   .backgroundColor('transparent')
        //   .fontColor('#666666')
        //   .onClick(() => {
        //     this.isPasswordVisible = !this.isPasswordVisible;
        //   })
        //   .margin({ right: 10 })
      }
      .width('100%')
      .height(40)
      .borderRadius(8)
      .backgroundColor('#eeeeee')
      .alignItems(VerticalAlign.Center)
      .margin({ top: 20 })

      Row() {
        Text('忘记密码')
          .fontSize(16)
        //.fontColor('#eeeeee')
      }
      .width('100%')
      .justifyContent(FlexAlign.End) //靠右对齐

      Button(this.isLoading ? "注册中..." : "注册")
        .backgroundColor("#0099FF")
        .fontColor(Color.White)
        .width('100%')
        .height(40)
        .margin({ top: 10, bottom: 5 })
        .borderRadius(8)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.registerUser();
        })

      // 返回登录页面按钮
      Button("返回登录")
        .backgroundColor("transparent")
        .fontColor("#0099FF")
        .width('100%')
        .height(40)
        .margin({ top: 5 })
        .borderRadius(8)
        .border({ width: 1, color: "#0099FF" })
        .onClick(() => {
          router.back();
        })

    }
    .padding({left:25,right:25})
    .height('100%')
    .width('100%')
    .linearGradient({//渐变
      direction:GradientDirection.RightTop,
      colors: [[0xE5FAF9, 0], [0xF8F6F5, 0.5]]
    })
  }

  // 注册用户方法
  async registerUser() {
    if (!this.account || !this.password) {
      console.error('账号和密码不能为空');
      promptAction.showToast({ message: '账号和密码不能为空', duration: 2000 });
      return;
    }

    // 设置加载状态
    this.isLoading = true;

    try {
      let httpRequest = http.createHttp();
      let response = await httpRequest.request(
        this.serverUrl + "/api/register",
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({
            account: this.account,
            password: this.password
          })
        }
      );

      if (response.responseCode === 200) {
        let result: ApiResponse = JSON.parse(response.result.toString());
        if (result.code === 0) {
          console.info('注册成功');
          promptAction.showToast({ message: '注册成功', duration: 2000 });
          // 注册成功后跳转到登录页面
          setTimeout(() => {
            router.replaceUrl({ url: 'pages/WeatherLogin' });
          }, 1500);
        } else {
          console.error('注册失败:', result.message);
          promptAction.showToast({ message: `注册失败: ${result.message}`, duration: 2000 });
        }
      } else if (response.responseCode === 409) {
        console.error('注册失败: 用户名已存在');
        promptAction.showToast({ message: '用户名已存在，请更换账号', duration: 2000 });
      } else {
        console.error('注册请求失败:', response.responseCode);
        promptAction.showToast({ message: `注册请求失败: ${response.responseCode}`, duration: 2000 });
      }
    } catch (error) {
      console.error('注册请求失败:', error);
      promptAction.showToast({ message: `注册请求失败: ${error}`, duration: 2000 });
    } finally {
      // 重置加载状态
      this.isLoading = false;
    }
  }
}