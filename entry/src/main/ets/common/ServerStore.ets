import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { ServerConfig } from '../model/Models';

const STORE_NAME: string = 'yuedu_config';
const KEY_BASE_URL: string = 'baseUrl';
const KEY_TOKEN: string = 'apiToken';

/**
 * 服务器地址与访问令牌的本地持久化（Preferences）。
 * 令牌是服务端「设置 → 手机接入」里显示的访问令牌，不要和 GitHub token 混淆。
 */
export class ServerStore {
  static async load(context: common.UIAbilityContext): Promise<ServerConfig> {
    const store: preferences.Preferences = await preferences.getPreferences(context, STORE_NAME);
    const baseUrl: string = await store.get(KEY_BASE_URL, '') as string;
    const token: string = await store.get(KEY_TOKEN, '') as string;
    const config: ServerConfig = {
      baseUrl: baseUrl,
      token: token
    };
    return config;
  }

  static async save(context: common.UIAbilityContext, config: ServerConfig): Promise<void> {
    const store: preferences.Preferences = await preferences.getPreferences(context, STORE_NAME);
    await store.put(KEY_BASE_URL, config.baseUrl);
    await store.put(KEY_TOKEN, config.token);
    await store.flush();
  }
}
