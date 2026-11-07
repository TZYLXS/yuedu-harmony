import { BusinessError } from '@ohos.base';
import hilog from '@ohos.hilog';
import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';

const DOMAIN: number = 0x0000;
const TAG: string = 'yuedu';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err: BusinessError) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'loadContent failed: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'loadContent succeeded');
    });
  }
}
