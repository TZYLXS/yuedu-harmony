import { ApiClient } from './ApiClient';

/**
 * WebDAV 接入助手。
 * 服务端把书架挂在 /dav/ 下，用户名任意，密码填访问令牌：
 *   /dav/books/   已下载书籍（只读 .txt）
 *   /dav/backup/  可读写，接 Legado 的「备份与恢复 → WebDAV」
 */
export class WebDavHelper {
  static root(baseUrl: string): string {
    return ApiClient.normalizeBase(baseUrl) + '/dav/';
  }

  static books(baseUrl: string): string {
    return ApiClient.normalizeBase(baseUrl) + '/dav/books/';
  }

  static backup(baseUrl: string): string {
    return ApiClient.normalizeBase(baseUrl) + '/dav/backup/';
  }

  static accountHint(): string {
    return '用户名任意，密码填「设置」里的访问令牌';
  }

  static usageHint(): string {
    return '在文件管理器里添加 WebDAV 服务器，或填进「阅读」的备份与恢复 → WebDAV';
  }
}
