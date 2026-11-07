import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { ApiClient } from '../common/ApiClient';
import { ServerStore } from '../common/ServerStore';
import { ServerConfig } from '../model/Models';

/**
 * 设置页：服务器地址 + 访问令牌。
 * 令牌是 FnReader 服务端「设置 → 手机接入」里显示的访问令牌。
 */
@Component
export struct SettingsView {
  @Prop baseUrl: string = '';
  @Prop token: string = '';
  @State inputBase: string = '';
  @State inputToken: string = '';
  @State testing: boolean = false;
  @State status: string = '';
  onSaved: (baseUrl: string, token: string) => void = () => {
  };

  aboutToAppear(): void {
    this.inputBase = this.baseUrl;
    this.inputToken = this.token;
  }

  async save(): Promise<void> {
    const config: ServerConfig = {
      baseUrl: ApiClient.normalizeBase(this.inputBase),
      token: this.inputToken.trim()
    };
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    await ServerStore.save(context, config);
    this.inputBase = config.baseUrl;
    this.onSaved(config.baseUrl, config.token);
    promptAction.showToast({ message: '已保存', duration: 1500 });
  }

  async test(): Promise<void> {
    if (this.inputBase.length === 0 || this.inputToken.length === 0) {
      this.status = '请先填服务器地址和令牌';
      return;
    }
    this.testing = true;
    this.status = '';
    try {
      const client: ApiClient = new ApiClient(this.inputBase, this.inputToken);
      const info: string = await client.ping();
      this.status = '连接成功：' + info;
    } catch (err) {
      this.status = '连接失败：' + (err as Error).message;
    } finally {
      this.testing = false;
    }
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('设置')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F1F1F')
          .width('100%')
          .margin({ top: 16 })

        Column({ space: 10 }) {
          Text('服务器地址')
            .fontSize(13)
            .fontColor('#8A8A8A')
            .width('100%')
          TextInput({ text: this.inputBase, placeholder: 'http://192.168.1.10:1122' })
            .fontSize(14)
            .height(44)
            .backgroundColor('#F2F3F5')
            .borderRadius(10)
            .onChange((value: string) => {
              this.inputBase = value;
            })

          Text('访问令牌')
            .fontSize(13)
            .fontColor('#8A8A8A')
            .width('100%')
            .margin({ top: 6 })
          TextInput({ text: this.inputToken, placeholder: '服务端「设置 → 手机接入」里的令牌' })
            .type(InputType.Password)
            .fontSize(14)
            .height(44)
            .backgroundColor('#F2F3F5')
            .borderRadius(10)
            .onChange((value: string) => {
              this.inputToken = value;
            })

          Row({ space: 10 }) {
            Button('保存')
              .layoutWeight(1)
              .height(40)
              .onClick(() => {
                this.save();
              })
            Button(this.testing ? '检查中…' : '检查连接')
              .layoutWeight(1)
              .height(40)
              .backgroundColor('#EDEFF1')
              .fontColor('#333333')
              .enabled(!this.testing)
              .onClick(() => {
                this.test();
              })
          }
          .width('100%')
          .margin({ top: 6 })

          if (this.status.length > 0) {
            Text(this.status)
              .fontSize(12)
              .fontColor(this.status.startsWith('连接成功') ? '#2E7D32' : '#C62828')
              .width('100%')
          }
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)

        Column({ space: 6 }) {
          Text('说明')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F1F1F')
            .width('100%')
          Text('· 服务地址填飞牛 NAS 的 IP 与端口，默认 1122；可省略 http://')
            .fontSize(12)
            .fontColor('#8A8A8A')
          Text('· 令牌用于 /api/m/*、WebDAV 与书源桥，服务端重置令牌后需要重新填')
            .fontSize(12)
            .fontColor('#8A8A8A')
          Text('· 首次连接会请求 ohos.permission.INTERNET，需要 NAS 与手机在同一局域网')
            .fontSize(12)
            .fontColor('#8A8A8A')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
      }
      .padding({ left: 14, right: 14, bottom: 20 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
    .scrollBar(BarState.Off)
  }
}
