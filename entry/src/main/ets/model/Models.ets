/**
 * 与 FnReader 服务端 /api/m/* 返回结构一一对应的数据模型。
 * 字段名保持服务端原样，避免二次映射出错。
 */

export interface ShelfBook {
  bookUrl: string;
  name: string;
  author: string;
  coverUrl: string;
  intro: string;
  kind: string;
  origin: string;
  originName: string;
  lastChapter: string;
  durChapterIndex: number;
  durChapterPos: number;
  durChapterTitle: string;
  durChapterTime: number;
  totalChapterNum: number;
}

export interface ShelfResponse {
  books: ShelfBook[];
}

export interface ChapterInfo {
  index: number;
  title: string;
  url: string;
}

export interface TocResponse {
  name: string;
  author: string;
  chapters: ChapterInfo[];
}

export interface ContentResponse {
  bookUrl: string;
  title: string;
  index: number;
  total: number;
  prev: string;
  next: string;
  paragraphs: string[];
  cached: boolean;
}

export interface ApiInfo {
  app: string;
  version: string;
  tokenRequired: boolean;
  endpoints: string[];
}

export interface SearchResponse {
  key: string;
  books: ShelfBook[];
}

export interface ProgressBody {
  bookUrl: string;
  index: number;
  pos: number;
  title: string;
}

export interface ServerConfig {
  baseUrl: string;
  token: string;
}
