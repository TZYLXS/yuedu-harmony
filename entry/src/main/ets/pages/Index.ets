import common from '@ohos.app.ability.common';
import { ServerStore } from '../common/ServerStore';
import { ServerConfig } from '../model/Models';
import { AccessView } from '../view/AccessView';
import { SettingsView } from '../view/SettingsView';
import { ShelfView } from '../view/ShelfView';

@Entry
@Component
struct Index {
  @State baseUrl: string = '';
  @State token: string = '';
  @State ready: boolean = false;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    try {
      const config: ServerConfig = await ServerStore.load(context);
      this.baseUrl = config.baseUrl;
      this.token = config.token;
    } catch (err) {
      this.baseUrl = '';
      this.token = '';
    }
    this.ready = true;
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        if (this.ready) {
          ShelfView({ baseUrl: this.baseUrl, token: this.token })
        }
      }
      .tabBar('书架')

      TabContent() {
        if (this.ready) {
          AccessView({ baseUrl: this.baseUrl, token: this.token })
        }
      }
      .tabBar('接入')

      TabContent() {
        if (this.ready) {
          SettingsView({
            baseUrl: this.baseUrl,
            token: this.token,
            onSaved: (baseUrl: string, token: string) => {
              this.baseUrl = baseUrl;
              this.token = token;
            }
          })
        }
      }
      .tabBar('设置')
    }
    .barMode(BarMode.Fixed)
    .barHeight(56)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
  }
}
