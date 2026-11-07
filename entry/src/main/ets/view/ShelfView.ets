import router from '@ohos.router';
import { ApiClient } from '../common/ApiClient';
import { ShelfBook } from '../model/Models';

/**
 * 书架页：对应 GET /api/m/shelf，按最近阅读排序。
 */
@Component
export struct ShelfView {
  @Prop @Watch('onConfigChanged') baseUrl: string = '';
  @Prop @Watch('onConfigChanged') token: string = '';
  @State books: ShelfBook[] = [];
  @State loading: boolean = false;
  @State message: string = '';

  aboutToAppear(): void {
    this.refresh();
  }

  onConfigChanged(): void {
    this.refresh();
  }

  async refresh(): Promise<void> {
    if (this.baseUrl.length === 0 || this.token.length === 0) {
      this.books = [];
      this.message = '先在「设置」里填服务器地址和访问令牌';
      return;
    }
    this.loading = true;
    this.message = '';
    try {
      const client: ApiClient = new ApiClient(this.baseUrl, this.token);
      const response = await client.shelf();
      this.books = response.books;
      if (this.books.length === 0) {
        this.message = '书架是空的，先在服务端加书';
      }
    } catch (err) {
      this.message = '加载失败：' + (err as Error).message;
    } finally {
      this.loading = false;
    }
  }

  openBook(book: ShelfBook): void {
    router.pushUrl({
      url: 'pages/Reader',
      params: {
        bookUrl: book.bookUrl,
        name: book.name,
        index: book.durChapterIndex,
        baseUrl: this.baseUrl,
        token: this.token
      }
    });
  }

  build() {
    Column() {
      Row() {
        Text('书架')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F1F1F')
        Blank()
        Button('刷新')
          .fontSize(13)
          .height(30)
          .backgroundColor('#EDEFF1')
          .fontColor('#333333')
          .onClick(() => {
            this.refresh();
          })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 16, bottom: 8 })

      if (this.message.length > 0) {
        Text(this.message)
          .fontSize(13)
          .fontColor('#8A8A8A')
          .width('100%')
          .padding({ left: 18, right: 18, bottom: 8 })
      }

      if (this.loading) {
        LoadingProgress()
          .width(36)
          .height(36)
          .margin({ top: 24 })
      }

      List({ space: 10 }) {
        ForEach(this.books, (book: ShelfBook) => {
          ListItem() {
            Row() {
              Image(ApiClient.coverUrl(this.baseUrl, this.token, book.bookUrl))
                .width(44)
                .height(60)
                .borderRadius(6)
                .objectFit(ImageFit.Cover)
                .backgroundColor('#EDEFF1')
                .margin({ right: 12 })

              Column() {
                Text(book.name)
                  .fontSize(16)
                  .fontColor('#1F1F1F')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                Text(book.author.length > 0 ? book.author : '未知作者')
                  .fontSize(12)
                  .fontColor('#8A8A8A')
                  .margin({ top: 4 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                Text(book.durChapterTitle.length > 0 ? '读到：' + book.durChapterTitle : '未开始阅读')
                  .fontSize(12)
                  .fontColor('#B0B0B0')
                  .margin({ top: 4 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text(book.durChapterIndex + 1 + '/' + book.totalChapterNum)
                .fontSize(12)
                .fontColor('#9A9A9A')
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .alignItems(VerticalAlign.Center)
          }
          .onClick(() => {
            this.openBook(book);
          })
        }, (book: ShelfBook) => book.bookUrl + '-' + book.durChapterIndex)
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 14, right: 14, bottom: 12 })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
  }
}
