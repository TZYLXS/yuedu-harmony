import http from '@ohos.net.http';
import {
  ApiInfo,
  ContentResponse,
  ProgressBody,
  SearchResponse,
  ShelfResponse,
  TocResponse
} from '../model/Models';

/**
 * FnReader /api/m/* 客户端。
 * 所有请求都带 X-Api-Token 头；令牌也可以放在 query 的 token 参数里。
 * 服务端返回非 200 时抛出的 Error 的 message 就是 body 里的 error 字段。
 */
export class ApiClient {
  private baseUrl: string;
  private token: string;

  constructor(baseUrl: string, token: string) {
    this.baseUrl = ApiClient.normalizeBase(baseUrl);
    this.token = token.trim();
  }

  /**
   * 允许用户输入 192.168.1.10:1122 这种省略协议的地址，并去掉尾部斜杠。
   */
  static normalizeBase(input: string): string {
    let value: string = input.trim();
    if (value.length === 0) {
      return '';
    }
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'http://' + value;
    }
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  base(): string {
    return this.baseUrl;
  }

  private async send(method: http.RequestMethod, path: string, body: string): Promise<string> {
    const headers: Record<string, string> = {};
    headers['X-Api-Token'] = this.token;
    headers['Accept'] = 'application/json';
    if (body.length > 0) {
      headers['Content-Type'] = 'application/json';
    }
    const options: http.HttpRequestOptions = {
      method: method,
      header: headers,
      connectTimeout: 10000,
      readTimeout: 30000,
      expectDataType: http.HttpDataType.STRING,
      usingCache: false
    };
    const request = http.createHttp();
    try {
      const response = await request.request(this.baseUrl + path, options);
      const code: number = response.responseCode as number;
      const text: string = response.result as string;
      if (code !== 200) {
        throw new Error(ApiClient.pickError(code, text));
      }
      return text;
    } finally {
      request.destroy();
    }
  }

  private static pickError(code: number, text: string): string {
    try {
      const payload: Record<string, string> = JSON.parse(text) as Record<string, string>;
      if (payload.error !== undefined && payload.error.length > 0) {
        return payload.error;
      }
    } catch (err) {
      // 非 JSON 响应，退回状态码
    }
    return 'HTTP ' + code;
  }

  async info(): Promise<ApiInfo> {
    const text: string = await this.send(http.RequestMethod.GET, '/api/m/info', '');
    return JSON.parse(text) as ApiInfo;
  }

  /** 连通用检查：能拿到 info 就算配置正确 */
  async ping(): Promise<string> {
    const info: ApiInfo = await this.info();
    return info.app + ' ' + info.version;
  }

  async shelf(): Promise<ShelfResponse> {
    const text: string = await this.send(http.RequestMethod.GET, '/api/m/shelf', '');
    return JSON.parse(text) as ShelfResponse;
  }

  async search(key: string, limit: number): Promise<SearchResponse> {
    const path: string = '/api/m/search?key=' + encodeURIComponent(key) + '&limit=' + limit;
    const text: string = await this.send(http.RequestMethod.GET, path, '');
    return JSON.parse(text) as SearchResponse;
  }

  async toc(bookUrl: string): Promise<TocResponse> {
    const path: string = '/api/m/toc?url=' + encodeURIComponent(bookUrl);
    const text: string = await this.send(http.RequestMethod.GET, path, '');
    return JSON.parse(text) as TocResponse;
  }

  async content(bookUrl: string, index: number): Promise<ContentResponse> {
    const path: string = '/api/m/content?url=' + encodeURIComponent(bookUrl) + '&index=' + index;
    const text: string = await this.send(http.RequestMethod.GET, path, '');
    return JSON.parse(text) as ContentResponse;
  }

  async saveProgress(bookUrl: string, index: number, pos: number, title: string): Promise<void> {
    const body: ProgressBody = {
      bookUrl: bookUrl,
      index: index,
      pos: pos,
      title: title
    };
    await this.send(http.RequestMethod.POST, '/api/m/progress', JSON.stringify(body));
  }

  /**
   * 封面代理地址：服务端已处理防盗链，客户端直接交给 Image 组件。
   * 这里把 token 放在 query 上，因为 Image 组件没法加自定义请求头。
   */
  static coverUrl(baseUrl: string, token: string, bookUrl: string): string {
    const base: string = ApiClient.normalizeBase(baseUrl);
    return base + '/api/m/cover?token=' + encodeURIComponent(token.trim()) +
      '&url=' + encodeURIComponent(bookUrl);
  }
}
