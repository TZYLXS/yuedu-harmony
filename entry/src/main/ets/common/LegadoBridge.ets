import { ApiClient } from './ApiClient';

/**
 * 「阅读」APK 接入（Legado 书源桥）。
 *
 * 服务端会把整座书库包装成一份 Legado 书源：
 *   /api/m/booksource?token=<token>        → 书源 JSON
 *   legado://import/bookSource?src=<上面地址 URL 编码>  → 一键导入链接
 * 老安卓设备（4.4–5.1）装 yuedu-android4 后「网络导入」即可直连飞牛书库。
 */
export class LegadoBridge {
  /** 书源 JSON 地址 */
  static booksourceUrl(baseUrl: string, token: string): string {
    const base: string = ApiClient.normalizeBase(baseUrl);
    return base + '/api/m/booksource?token=' + encodeURIComponent(token.trim());
  }

  /** 给「阅读」APK 直接打开的导入链接 */
  static importLink(baseUrl: string, token: string): string {
    return 'legado://import/bookSource?src=' + encodeURIComponent(LegadoBridge.booksourceUrl(baseUrl, token));
  }

  /** 书源内部用于搜索的地址，便于排查 */
  static searchUrl(baseUrl: string, token: string, key: string): string {
    const base: string = ApiClient.normalizeBase(baseUrl);
    return base + '/api/m/legado/search?token=' + encodeURIComponent(token.trim()) +
      '&key=' + encodeURIComponent(key);
  }

  static hint(): string {
    return '在「阅读」APK 里选择「网络导入」，粘贴上面的 legado:// 链接即可；不用改 APK，也不用装模拟器。';
  }
}
