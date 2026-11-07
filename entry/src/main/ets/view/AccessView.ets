import pasteboard from '@ohos.pasteboard';
import promptAction from '@ohos.promptAction';
import { ApiClient } from '../common/ApiClient';
import { LegadoBridge } from '../common/LegadoBridge';
import { WebDavHelper } from '../common/WebDavHelper';

/**
 * 接入页：把服务端 README 里的三种接入方式在鸿蒙侧跑通。
 *   1) /api/m/* 手机接入（令牌鉴权）
 *   2) Legado 书源桥：一键生成 legado:// 导入链接
 *   3) WebDAV：书架与备份目录
 */
@Component
export struct AccessView {
  @Prop baseUrl: string = '';
  @Prop token: string = '';

  private async copy(text: string): Promise<void> {
    const data: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    await pasteboard.getSystemPasteboard().setData(data);
    promptAction.showToast({ message: '已复制', duration: 1500 });
  }

  private notReady(): boolean {
    return this.baseUrl.length === 0 || this.token.length === 0;
  }

  @Builder
  sectionTitle(title: string, desc: string) {
    Column() {
      Text(title)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F1F1F')
        .width('100%')
      Text(desc)
        .fontSize(12)
        .fontColor('#8A8A8A')
        .margin({ top: 4 })
        .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({ bottom: 10 })
  }

  @Builder
  valueRow(label: string, value: string) {
    Column() {
      Row() {
        Text(label)
          .fontSize(12)
          .fontColor('#8A8A8A')
          .width(64)
        Text(value.length > 0 ? value : '未配置')
          .fontSize(12)
          .fontColor('#333333')
          .layoutWeight(1)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Button('复制')
        .fontSize(12)
        .height(28)
        .margin({ top: 6 })
        .backgroundColor('#EDEFF1')
        .fontColor('#333333')
        .enabled(value.length > 0)
        .onClick(() => {
          this.copy(value);
        })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  build() {
    Scroll() {
      Column({ space: 12 }) {
        Text('接入')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F1F1F')
          .width('100%')
          .margin({ top: 16, bottom: 2 })

        if (this.notReady()) {
          Text('先在「设置」里填服务器地址和访问令牌，下面的地址才会生成')
            .fontSize(13)
            .fontColor('#D5761A')
            .width('100%')
            .padding(10)
            .backgroundColor('#FFF6E8')
            .borderRadius(8)
        }

        // 1. 手机接入 API
        Column() {
          this.sectionTitle('/api/m/*  手机接入', '所有接口需要 X-Api-Token 头，也可以放在 query 的 token 参数里')
          this.valueRow('服务地址', ApiClient.normalizeBase(this.baseUrl))
          this.valueRow('令牌', this.token)
          this.valueRow('书架示例', ApiClient.normalizeBase(this.baseUrl) + '/api/m/shelf')
          this.valueRow('正文示例', ApiClient.normalizeBase(this.baseUrl) + '/api/m/content?url=<bookUrl>&index=0')
          this.valueRow('搜索示例', ApiClient.normalizeBase(this.baseUrl) + '/api/m/search?key=<关键词>')
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)

        // 2. Legado 书源桥
        Column() {
          this.sectionTitle('Legado 书源桥', '服务端把整座书库包装成一份书源，APK 侧零改动')
          this.valueRow('书源 JSON', LegadoBridge.booksourceUrl(this.baseUrl, this.token))
          this.valueRow('导入链接', LegadoBridge.importLink(this.baseUrl, this.token))
          Text(LegadoBridge.hint())
            .fontSize(12)
            .fontColor('#8A8A8A')
            .width('100%')
            .margin({ top: 4 })
        }
        .width('100%')
        .padding(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)

        // 3. WebDAV
        Column() {
          this.sectionTitle('WebDAV', WebDavHelper.accountHint())
          this.valueRow('根目录', WebDavHelper.root(this.baseUrl))
          this.valueRow('书籍（只读）', WebDavHelper.books(this.baseUrl))
          this.valueRow('备份（读写）', WebDavHelper.backup(this.baseUrl))
          Text(WebDavHelper.usageHint())
            .fontSize(12)
            .fontColor('#8A8A8A')
            .width('100%')
            .margin({ top: 4 })
        }
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
