import router from '@ohos.router';
import { ApiClient } from '../common/ApiClient';
import { ChapterInfo, ContentResponse, TocResponse } from '../model/Models';

interface ReaderParams {
  bookUrl: string;
  name: string;
  index: number;
  baseUrl: string;
  token: string;
}

/**
 * 阅读页：目录走 /api/m/toc，正文走 /api/m/content，翻章时上报 /api/m/progress。
 */
@Entry
@Component
struct Reader {
  @State title: string = '';
  @State paragraphs: string[] = [];
  @State index: number = 0;
  @State total: number = 0;
  @State loading: boolean = false;
  @State message: string = '';
  @State showToc: boolean = false;
  @State chapters: ChapterInfo[] = [];
  @State fontSize: number = 17;

  private bookUrl: string = '';
  private bookName: string = '';
  private client: ApiClient = new ApiClient('', '');
  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
    const params: ReaderParams = router.getParams() as ReaderParams;
    this.bookUrl = params.bookUrl;
    this.bookName = params.name;
    this.index = params.index;
    this.client = new ApiClient(params.baseUrl, params.token);
    this.loadToc();
    this.loadChapter(this.index);
  }

  async loadToc(): Promise<void> {
    try {
      const toc: TocResponse = await this.client.toc(this.bookUrl);
      this.chapters = toc.chapters;
      this.total = toc.chapters.length;
    } catch (err) {
      this.message = '目录加载失败：' + (err as Error).message;
    }
  }

  async loadChapter(idx: number): Promise<void> {
    if (idx < 0) {
      return;
    }
    if (this.total > 0 && idx >= this.total) {
      return;
    }
    this.loading = true;
    this.message = '';
    try {
      const content: ContentResponse = await this.client.content(this.bookUrl, idx);
      this.index = content.index;
      this.title = content.title;
      this.paragraphs = content.paragraphs;
      this.total = content.total;
      this.scroller.scrollTo({ xOffset: 0, yOffset: 0 });
      this.reportProgress(content.index, content.title);
    } catch (err) {
      this.message = '正文加载失败：' + (err as Error).message;
    } finally {
      this.loading = false;
    }
  }

  /** 进度上报失败不影响阅读，只吞掉错误 */
  async reportProgress(idx: number, title: string): Promise<void> {
    try {
      await this.client.saveProgress(this.bookUrl, idx, 0, title);
    } catch (err) {
      console.warn('保存进度失败：' + (err as Error).message);
    }
  }

  @Builder
  topBar() {
    Row() {
      Button('目录')
        .fontSize(13)
        .height(30)
        .backgroundColor('#EDEFF1')
        .fontColor('#333333')
        .onClick(() => {
          this.showToc = true;
        })
      Text(this.bookName.length > 0 ? this.bookName : '阅读')
        .fontSize(14)
        .fontColor('#1F1F1F')
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .margin({ left: 8, right: 8 })
      Button('返回')
        .fontSize(13)
        .height(30)
        .backgroundColor('#EDEFF1')
        .fontColor('#333333')
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  bottomBar() {
    Row({ space: 10 }) {
      Button('上一章')
        .fontSize(13)
        .height(34)
        .layoutWeight(1)
        .backgroundColor('#EDEFF1')
        .fontColor('#333333')
        .enabled(this.index > 0)
        .onClick(() => {
          this.loadChapter(this.index - 1);
        })
      Button('A-')
        .fontSize(13)
        .height(34)
        .width(52)
        .backgroundColor('#EDEFF1')
        .fontColor('#333333')
        .onClick(() => {
          if (this.fontSize > 13) {
            this.fontSize = this.fontSize - 1;
          }
        })
      Button('A+')
        .fontSize(13)
        .height(34)
        .width(52)
        .backgroundColor('#EDEFF1')
        .fontColor('#333333')
        .onClick(() => {
          if (this.fontSize < 24) {
            this.fontSize = this.fontSize + 1;
          }
        })
      Button('下一章')
        .fontSize(13)
        .height(34)
        .layoutWeight(1)
        .backgroundColor('#EDEFF1')
        .fontColor('#333333')
        .enabled(this.total === 0 || this.index + 1 < this.total)
        .onClick(() => {
          this.loadChapter(this.index + 1);
        })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  tocPanel() {
    Column() {
      Row() {
        Text('目录 · ' + this.chapters.length + ' 章')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F1F1F')
        Blank()
        Button('关闭')
          .fontSize(12)
          .height(28)
          .backgroundColor('#EDEFF1')
          .fontColor('#333333')
          .onClick(() => {
            this.showToc = false;
          })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 12, bottom: 8 })

      List() {
        ForEach(this.chapters, (chapter: ChapterInfo) => {
          ListItem() {
            Text(chapter.title)
              .fontSize(13)
              .fontColor(chapter.index === this.index ? '#0A59F7' : '#333333')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          }
          .onClick(() => {
            this.showToc = false;
            this.loadChapter(chapter.index);
          })
        }, (chapter: ChapterInfo) => chapter.index + '-')
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('72%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 12, bottomLeft: 12 })
  }

  build() {
    Stack({ alignContent: Alignment.End }) {
      Column() {
        this.topBar()

        if (this.loading) {
          LoadingProgress()
            .width(36)
            .height(36)
            .margin({ top: 24, bottom: 8 })
        }

        if (this.message.length > 0) {
          Text(this.message)
            .fontSize(13)
            .fontColor('#C62828')
            .padding(14)
        }

        Scroll(this.scroller) {
          Column() {
            Text(this.title)
              .fontSize(this.fontSize + 4)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F1F1F')
              .width('100%')
              .margin({ top: 12, bottom: 14 })

            ForEach(this.paragraphs, (paragraph: string, idx: number) => {
              Text(paragraph)
                .fontSize(this.fontSize)
                .lineHeight(this.fontSize * 1.8)
                .fontColor('#333333')
                .textAlign(TextAlign.JUSTIFY)
                .width('100%')
                .margin({ bottom: 10 })
            }, (paragraph: string, idx: number) => idx + '-' + paragraph.length)
          }
          .padding({ left: 20, right: 20, bottom: 24 })
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)

        this.bottomBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F7F7F5')

      if (this.showToc) {
        this.tocPanel()
      }
    }
    .width('100%')
    .height('100%')
  }
}
