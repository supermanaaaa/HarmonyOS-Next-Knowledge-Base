import { url } from '@kit.ArkTS'
import { LogUtil } from 'zcommon'
import { http } from '@kit.NetworkKit'
import { fileIo } from '@kit.CoreFileKit'


@Component
export struct ImageReloadComponent {
  @State isOnError: boolean = false
  @Require @State @Watch('updateSrc') src: PixelMap | ResourceStr | DrawableDescriptor = ''
  @Require @State imgAlt: string | Resource | PixelMap = ""
  @State objectFit: ImageFit = ImageFit.Cover
  @State objectRepeat: ImageRepeat = ImageRepeat.NoRepeat
  @State interpolation: ImageInterpolation = ImageInterpolation.Low
  @State renderMode: ImageRenderMode = ImageRenderMode.Original
  @State sourceSize: ISourceSize = { width: 0, height: 0 }
  @State syncLoad: boolean = false
  @State autoResize: boolean = false
  @State fitOriginalSize: boolean = false
  @State copyOption: CopyOptions = CopyOptions.None
  @State matchTextDirection: boolean = false
  @State privacySensitive: boolean = false
  @State draggableImg: boolean = false
  @State enableAnalyzer: boolean = false
  @State dynamicRangeMode: DynamicRangeMode = DynamicRangeMode.STANDARD
  // @State orientation: ImageRotateOrientation = ImageRotateOrientation.UP
  imageReload: ImageReloadComController = new ImageReloadComController()
  onComplete: () => void = () => {
  }
  onError: () => void = () => {
  }
  onFinish: () => void = () => {
  }

  async aboutToAppear(): Promise<void> {
    if (typeof this.src === 'string') {
      this.src = await this.imageReload.downloadImageToCache(this.src)
    }
  }

  async updateSrc() {
    if (typeof this.src === 'string') {
      // this.src = await this.imageReload.downloadImageToCache(this.src)
    }
  }

  build() {
    Image(this.src)// 核心属性
      .alt(this.imgAlt)
      .objectFit(this.objectFit)
      .objectRepeat(this.objectRepeat)
      .interpolation(this.interpolation)
      .renderMode(this.renderMode)
      .sourceSize(this.sourceSize)
      .syncLoad(this.syncLoad)
      .autoResize(this.autoResize)
      .fitOriginalSize(this.fitOriginalSize)
      .matchTextDirection(this.matchTextDirection)
      .privacySensitive(this.privacySensitive)
      .copyOption(this.copyOption)
      .draggable(this.draggableImg)
      .enableAnalyzer(this.enableAnalyzer)
      .dynamicRangeMode(this.dynamicRangeMode)// .orientation(this.orientation)
      .onComplete(() => this.onComplete())
      .onError(() => this.onError())
      .onFinish(() => this.onFinish())
  }
}


interface ISourceSize {
  width: number,
  height: number
}

abstract class AbstractImageCacheController {
  protected cacheDir: string = getContext(this).cacheDir;
  protected cacheFolder: string;
  protected currentDomainName: string;
  protected tag: string = 'ImageReloadComController';
  protected httpRequest = http.createHttp();
  protected downloadLocks: Map<string, Promise<string>> = new Map();

  constructor(cacheFolder?: string, currentDomainName?: string) {
    // 允许外部传入新的缓存文件夹和当前域名，否则使用默认值
    this.cacheFolder = cacheFolder?.trim() || 'download_image_default_cache';
    this.currentDomainName = currentDomainName?.trim() || 'chujingservice.com';
  }

  /**
   * 下载网络图片到缓存中，返回最终的本地文件路径（带 file:// 前缀）
   */
  public abstract downloadImageToCache(
    urlLink: string,
    onStartDownload?: () => void,
    onEndDownload?: () => void
  ): Promise<string>;

  /**
   * 清理缓存文件夹中的所有文件，返回是否成功
   */
  public abstract clearCache(): boolean;

  /**
   * 获取缓存文件夹中的所有文件列表
   */
  public abstract getCacheFiles(): string[];

  /**
   * 将下载图片的具体实现封装为内部方法
   */
  protected abstract _doDownload(
    urlLink: string,
    onStartDownload: () => void,
    onEndDownload: () => void
  ): Promise<string>;

  /**
   * 解析URL信息，抽取路径、文件名、扩展名等数据
   */
  protected abstract parseFileInfo(urlLink: string): IParseUrlInfo;
}

interface IParseUrlInfo {
  domainMatches: boolean;
  fileName: string;
  extension: string;
  domain: string;
  urlLink: string;
}

class ImageReloadComController extends AbstractImageCacheController {
  async downloadImageToCache(
    urlLink: string,
    onStartDownload: () => void = () => {
    },
    onEndDownload: () => void = () => {
    }
  ): Promise<string> {
    if (!urlLink) {
      return urlLink;
    }

    if (this.downloadLocks.has(urlLink)) {
      return this.downloadLocks.get(urlLink)!;
    }

    const promise = this._doDownload(urlLink, onStartDownload, onEndDownload);
    this.downloadLocks.set(urlLink, promise);
    try {
      return await promise;
    } finally {
      this.downloadLocks.delete(urlLink);
    }
  }

  public clearCache(): boolean {
    try {
      const cacheDir = `${this.cacheDir}/${this.cacheFolder}`;

      if (!fileIo.accessSync(cacheDir)) {
        LogUtil.d(this.tag, `缓存文件夹不存在: ${cacheDir}`);
        return true;
      }

      const files = fileIo.listFileSync(cacheDir);
      if (files.length === 0) {
        LogUtil.d(this.tag, `缓存文件夹为空: ${cacheDir}`);
        return true;
      }

      for (const file of files) {
        const filePath = `${cacheDir}/${file}`;
        fileIo.unlinkSync(filePath);
        LogUtil.d(this.tag, `已删除文件: ${filePath}`);
      }

      LogUtil.d(this.tag, `缓存清理完成: ${cacheDir}`);
      return true;
    } catch (error) {
      LogUtil.e(this.tag, `清理缓存失败: ${error.message}`);
      return false;
    }
  }

  public getCacheFiles(): string[] {
    try {
      const cacheDir = `${this.cacheDir}/${this.cacheFolder}`;

      if (!fileIo.accessSync(cacheDir)) {
        LogUtil.d(this.tag, `缓存文件夹不存在: ${cacheDir}`);
        return [];
      }

      const files = fileIo.listFileSync(cacheDir);
      LogUtil.d(this.tag, `缓存文件夹内容: ${JSON.stringify(files)}`);
      return files;
    } catch (error) {
      LogUtil.e(this.tag, `获取缓存文件列表失败: ${error.message}`);
      return [];
    }
  }

  protected async _doDownload(
    urlLink: string,
    onStartDownload: () => void,
    onEndDownload: () => void
  ): Promise<string> {
    onStartDownload();
    try {
      const parseUrlInfo = this.parseFileInfo(urlLink);
      if (!parseUrlInfo.domainMatches) {
        LogUtil.e(this.tag, `域名检测不通过: ${urlLink}`);
        return urlLink;
      }

      const localPath = `${this.cacheDir}/${this.cacheFolder}/${parseUrlInfo.fileName}.${parseUrlInfo.extension}`;
      const dirPath = `${this.cacheDir}/${this.cacheFolder}`;

      if (!fileIo.accessSync(dirPath)) {
        fileIo.mkdirSync(dirPath, true);
      }

      if (fileIo.accessSync(localPath)) {
        LogUtil.d(this.tag, `图片已存在: ${localPath}`);
        return `file://${localPath}`;
      }

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        readTimeout: 60_000,
        connectTimeout: 60_000,
        usingProxy: false,
      };

      const data = await this.httpRequest.request(urlLink, options);
      if (data?.responseCode !== http.ResponseCode.OK) {
        LogUtil.e(this.tag, `下载失败: ${data?.responseCode}`, urlLink);
        return urlLink;
      }

      const tempPath = `${localPath}.tmp`;
      const fileInfo = fileIo.openSync(tempPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      await fileIo.write(fileInfo.fd, data.result as ArrayBuffer);
      fileIo.closeSync(fileInfo.fd);
      fileIo.renameSync(tempPath, localPath);

      LogUtil.d(this.tag, `图片下载成功: ${localPath}`, urlLink);
      return `file://${localPath}`;
    } catch (error) {
      LogUtil.e(this.tag, `下载错误: ${error.message}`, urlLink);
      return urlLink;
    } finally {
      onEndDownload();
      this.httpRequest.destroy();
    }
  }

  protected parseFileInfo(urlLink: string): IParseUrlInfo {
    try {
      const parsedUrl = url.URL.parseURL(urlLink);
      if (!parsedUrl) {
        return {
          domainMatches: false,
          fileName: '',
          extension: '',
          domain: '',
          urlLink
        };
      }
      const pathname = parsedUrl.pathname || '';
      const domain = parsedUrl.hostname || '';
      const domainMatches = domain.includes(this.currentDomainName);
      const filePathParts = pathname.split('/').filter(Boolean);
      if (filePathParts.length === 0) {
        return {
          domainMatches,
          fileName: '',
          extension: '',
          domain,
          urlLink
        };
      }
      const fileWithExt = filePathParts.pop() || '';
      const extension = fileWithExt.includes('.') ? fileWithExt.split('.').pop() || '' : '';
      const fileBaseName = extension ? fileWithExt.slice(0, -extension.length - 1) : fileWithExt;
      const fullPathPrefix = filePathParts.join('_');
      const fileName = fullPathPrefix ? `${fullPathPrefix}_${fileBaseName}` : fileBaseName;
      return {
        domainMatches,
        fileName,
        extension,
        domain,
        urlLink,
      };
    } catch (error) {
      LogUtil.e(this.tag, `URL解析失败: ${error.message}`);
      return {
        domainMatches: false,
        fileName: '',
        extension: '',
        domain: '',
        urlLink
      };
    }
  }
}

/*
class ImageReloadComController {
  private cacheDir: string = getContext(this).cacheDir
  private cacheFolder: string = 'download_image_default_cache'
  private tag: string = 'ImageReloadComController'
  private currentDomainName: string = 'chujingservice.com'
  private httpRequest = http.createHttp()
  private downloadLocks: Map<string, Promise<string>> = new Map()

  constructor(cacheFolder?: string, currentDomainName?: string) {
    this.cacheFolder = cacheFolder?.trim() || this.cacheFolder
    this.currentDomainName = currentDomainName?.trim() || this.currentDomainName
  }

  */
/**
 * 下载网络图片到缓存中
 * @returns {string} 返回路径
 */
/*

  async downloadImageToCache(
    urlLink: string,
    onStartDownload: () => void = () => {
    },
    onEndDownload: () => void = () => {
    }
  ): Promise<string> {
    if (!urlLink) {
      return urlLink
    }

    if (this.downloadLocks.has(urlLink)) {
      return this.downloadLocks.get(urlLink)!
    }

    const promise = this._doDownload(urlLink, onStartDownload, onEndDownload)
    this.downloadLocks.set(urlLink, promise)
    try {
      return await promise
    } finally {
      this.downloadLocks.delete(urlLink)
    }
  }

  */
/**
 * 清理缓存文件夹中的所有文件
 * @returns {boolean} 是否清理成功
 */
/*

  public clearCache(): boolean {
    try {
      const cacheDir = `${this.cacheDir}/${this.cacheFolder}`

      if (!fileIo.accessSync(cacheDir)) {
        LogUtil.d(this.tag, `缓存文件夹不存在: ${cacheDir}`)
        return true
      }

      const files = fileIo.listFileSync(cacheDir)
      if (files.length === 0) {
        LogUtil.d(this.tag, `缓存文件夹为空: ${cacheDir}`)
        return true
      }

      for (const file of files) {
        const filePath = `${cacheDir}/${file}`
        fileIo.unlinkSync(filePath)
        LogUtil.d(this.tag, `已删除文件: ${filePath}`)
      }

      LogUtil.d(this.tag, `缓存清理完成: ${cacheDir}`)
      return true
    } catch (error) {
      LogUtil.e(this.tag, `清理缓存失败: ${error.message}`)
      return false
    }
  }

  */
/**
 * 获取缓存文件夹中的文件列表
 * @returns {string[]} 缓存文件夹中的文件列表
 */
/*

  public getCacheFiles(): string[] {
    try {
      const cacheDir = `${this.cacheDir}/${this.cacheFolder}`

      if (!fileIo.accessSync(cacheDir)) {
        LogUtil.d(this.tag, `缓存文件夹不存在: ${cacheDir}`)
        return []
      }

      const files = fileIo.listFileSync(cacheDir)
      LogUtil.d(this.tag, `缓存文件夹内容: ${JSON.stringify(files)}`)
      return files
    } catch (error) {
      LogUtil.e(this.tag, `获取缓存文件列表失败: ${error.message}`)
      return []
    }
  }

  private async _doDownload(
    urlLink: string,
    onStartDownload: () => void,
    onEndDownload: () => void
  ): Promise<string> {
    onStartDownload()
    try {
      const parseUrlInfo = this.parseFileInfo(urlLink)
      if (!parseUrlInfo.domainMatches) {
        LogUtil.e(this.tag, `域名检测不通过: ${urlLink}`)
        return urlLink
      }

      const localPath = `${this.cacheDir}/${this.cacheFolder}/${parseUrlInfo.fileName}.${parseUrlInfo.extension}`
      const dirPath = `${this.cacheDir}/${this.cacheFolder}`

      if (!fileIo.accessSync(dirPath)) {
        fileIo.mkdirSync(dirPath, true)
      }

      if (fileIo.accessSync(localPath)) {
        LogUtil.d(this.tag, `图片已存在: ${localPath}`)
        return `file://${localPath}`
      }

      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
        readTimeout: 60_000,
        connectTimeout: 60_000,
        usingProxy: false,
      }

      const data = await this.httpRequest.request(urlLink, options)
      if (data?.responseCode !== http.ResponseCode.OK) {
        LogUtil.e(this.tag, `下载失败: ${data?.responseCode}`, urlLink)
        return urlLink
      }

      const tempPath = `${localPath}.tmp`
      const fileInfo = fileIo.openSync(tempPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
      await fileIo.write(fileInfo.fd, data.result as ArrayBuffer)
      fileIo.closeSync(fileInfo.fd)
      fileIo.renameSync(tempPath, localPath)

      LogUtil.d(this.tag, `图片下载成功: ${localPath}`, urlLink)
      return `file://${localPath}`
    } catch (error) {
      LogUtil.e(this.tag, `下载错误: ${error.message}`, urlLink)
      return urlLink
    } finally {
      onEndDownload()
      this.httpRequest.destroy()
    }
  }

  private parseFileInfo(urlLink: string): IParseUrlInfo {
    try {
      const parsedUrl = url.URL.parseURL(urlLink)
      if (!parsedUrl) {
        return {
          domainMatches: false,
          fileName: '',
          extension: '',
          domain: '',
          urlLink
        }
      }
      const pathname = parsedUrl.pathname || ''
      const domain = parsedUrl.hostname || ''
      const domainMatches = domain.includes(this.currentDomainName)
      const filePathParts = pathname.split('/').filter(Boolean) // 去除空字符串
      if (filePathParts.length === 0) {
        return {
          domainMatches,
          fileName: '',
          extension: '',
          domain,
          urlLink
        }
      }
      const fileWithExt = filePathParts.pop() || ''
      const extension = fileWithExt.includes('.') ? fileWithExt.split('.').pop() || '' : ''
      const fileBaseName = extension ? fileWithExt.slice(0, -extension.length - 1) : fileWithExt
      const fullPathPrefix = filePathParts.join('_')
      const fileName = fullPathPrefix ? `${fullPathPrefix}_${fileBaseName}` : fileBaseName
      return {
        domainMatches,
        fileName,
        extension,
        domain,
        urlLink,
      }
    } catch (error) {
      LogUtil.e(this.tag, `URL解析失败: ${error.message}`)
      return {
        domainMatches: false,
        fileName: '',
        extension: '',
        domain: '',
        urlLink
      }
    }
  }
}

interface IParseUrlInfo {
  domainMatches: boolean
  fileName: string
  extension: string
  domain: string
  urlLink: string
}
*/
