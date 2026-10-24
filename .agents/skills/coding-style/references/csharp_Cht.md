# C# 程式碼風格標準

本文件定義 C# 開發的嚴格程式碼標準與架構模式.

## 程式碼標準

### 命名空間與 Using 指令
- 使用**檔案範疇命名空間** (namespace 不加大括號).
- `using` 指令依**字母順序**排列.

### 格式化 (120 字元限制)
- **方法呼叫與宣告**: 除非超過 120 字元,否則參數保持同行. 換行時,所有參數一起縮排至下一行.
```csharp
// 正確換行範例
public ProductRepository(
    IOptions<Settings> settings, IUnitOfWork unitOfWork, ILogger<ProductRepository> logger)
```
- **If 陳述式**: 使用單行防衛子句. 將複雜條件提取為變數.
```csharp
if (isFirstBuyMember) return GROUP_FIRST_BUY;
```
- **Early Return / Early Continue**: 優先以反轉條件提早離開，而非將主要邏輯包在巢狀區塊內。方法中用 `return`，迴圈中用 `continue`。
```csharp
// 優先這樣寫:
if (!res.IsPass) continue;
DoWork(res);

// 而非這樣:
if (res.IsPass)
{
    DoWork(res);
}
```

### 不用魔術數字
- 領域代碼值不以裸字面值比較、指派或傳遞 (`!= 0`、`== 1`、`Type = 3`). 改用具名成員: `Enumeration` 類別用 `<Enumeration>.<Member>.Id`,欄位以 `int` 儲存的 C# `enum` 用 `(int)<Enum>.<Member>`.
- 若這組代碼還沒有具名型別,就新增一個,為每個已知值 (含代表「無」的值) 建立成員,而不是保留字面值再加註解.
- 意思是「任何非預設值」的判斷,與具名的預設成員比較;不逐一列舉其他成員.
```csharp
// 優先
if (coupon.MarginPassType != (int)MarginPassType.None) return false;
.Where(x => x.MemberUseType == PromotionMemberUseType.AllMember.Id)

// 避免
if (coupon.MarginPassType != 0) return false;
.Where(x => x.MemberUseType == 0)
```
- SQL 字串適用同一規則;見下方.

### SQL 字串
- SQL 必須從**最左欄**開始 (忽略 C# 縮排).
- **關鍵字大寫**: `SELECT`、`FROM`、`WHERE`、`AND`、`OR`、`JOIN`、`LEFT JOIN`、`ON`、`IS NULL`、`LIKE`、`AS`、`UNION ALL` 等.
- **運算子兩側補空格**: `r.is_delete = 0` (而非 `r.is_delete=0`);`x = @p` (而非 `x=@p`).
- `SELECT` 欄位各佔一行,與 `AS` 對齊.
- `WHERE` 條件以 `  AND` 開頭 (兩個空格).
```sql
SELECT psi.item_id          AS ProductId,
       p.id                 AS PromotionId
FROM promotion_scope_items psi
WHERE psi.item_type = 3
  AND psi.is_exclude = 0
```
- **領域代碼欄位不用魔術數字**: 當欄位對應領域 `Enumeration` 時,以參數傳入 `<Enum>.<Member>.Id`,而非字面值.
```csharp
// 優先 — 參數來自領域 Enumeration
parameters.Add("@homeDeliveryType", DeliveryType.HomeDelivery.Id);
// SQL:  WHERE delivery_type = @homeDeliveryType

// 避免 — SQL 中的魔術數字
// SQL:  WHERE delivery_type = 1
```

## 專案特定模式

### 實體設定 (EntityConfig)
- **極簡主義**: 只使用 `ToTable`、`Ignore(DomainEvents)`、`HasKey` 與 `Property().HasColumnName()`.
- 在 `OnModelCreating` 的**底部**新增 `ApplyConfiguration` 呼叫.
```csharp
public void Configure(EntityTypeBuilder<Entity> builder)
{
    builder.ToTable("table_name", Schema.DEFAULT);
    builder.Ignore(b => b.DomainEvents);
    builder.HasKey(c => c.Id);
    builder.Property(e => e.UserId).HasColumnName("user_id");
}
```

### Dapper 查詢結果映射
- 將 Dapper 查詢結果讀進**專用查詢模型** (例如 `Application/Models/<Audience>/` 下的 `XxxQueryModel`),再映射為回應 ViewModel.
- **不要**直接 `Read<>` 進 API ViewModel — 讓 DB 讀取結構與 API 契約解耦.
```csharp
var rows = (await conn.QueryAsync<MemberReceiverQueryModel>(sql, p)).ToList();
var vo = rows.Select(x => new MemberReceiverItemVo(x)).ToList();
```

### 以呼叫者需求為準的介面
- 只公開呼叫者需要的能力,而不是實作類別的每個方法. 內部步驟保持 private.
- 這能避免呼叫者繞過完整流程,也讓實作細節不進入公開契約.

避免公開載入與回填快取所用的步驟:
```csharp
public interface ISettingCache
{
    Task<SettingDto> GetAsync();
    Task<SettingDto> LoadFromDatabaseAsync();
    Task WriteCacheAsync(SettingDto setting);
}
```
優先提供符合呼叫者實際操作的契約;載入與寫入方法在實作中保持 private:
```csharp
public interface ISettingCache
{
    Task<SettingDto> GetAsync();
}
```

### 空介面
- 若空介面沒有實際用於標記行為、泛型約束、註冊或探索,就不建立或保留.
- 未使用的繼承層會增加追查與維護工作,卻沒有提供能力或約束.

若 `ICacheRepository<T>` 沒有上述用途,就移除這個空的父介面,而不是只為了分類而繼承它:
```csharp
// 避免未使用的父介面.
public interface ICacheRepository<T> { }
public interface IProductCache : ICacheRepository<ProductDto>
{
    Task<ProductDto> GetAsync(int productId);
}
```
```csharp
// 優先保留實際契約.
public interface IProductCache
{
    Task<ProductDto> GetAsync(int productId);
}
```

### 僅供 Logging 使用的 Context
- 優先使用既有 logger 與區域變數,而不是只為追蹤目前 logging 階段,就在方法之間傳遞可變 context.
- 這類 context 必須在每個步驟更新. 清理流程可能覆寫階段,讓 log 描述清理階段而非原本的失敗.
- 保留確實管理共用狀態或生命週期的 context. 保留必要的鎖、清理與例外處理.

避免只為診斷而維護額外狀態:
```csharp
context.Stage = "ReadCache";
context.Key = key;
var value = await ReadAsync(key);

context.Stage = "WriteCache";
await WriteAsync(key, value);
```
優先記錄完整例外及有用的識別資訊:
```csharp
catch (Exception exception)
{
    _logger.LogWarning(exception, "Failed to get product cache. ProductId: {ProductId}", productId);
    throw;
}
```
重新拋出只是示範例外向外傳遞的契約;應保留方法既定的降級或向外傳遞行為. 需要時補充特定診斷資訊,而不是預設建立一套追蹤框架.

### 沿呼叫鏈一致使用參數模型
- 當多個參數屬於同一組有意義的業務資料時,先找既有模型/介面模式,再考慮新增.
- 一致調整建構式、更新方法及上游呼叫端. 只在最底層包裝參數,會讓上游仍保留長串參數及位置傳錯的問題.
- 不要只為了縮短方法宣告而將無關參數包在一起.

不要反覆傳遞個別分類 ID:
```csharp
entity.UpdateCategories(command.D1CategoryId, command.D2CategoryId, command.D3CategoryId);
```
改為重用既有分類契約:
```csharp
public void UpdateCategories(IProductCategoriesModel categories)
{
    D1CategoryId = categories.D1CategoryId;
    D2CategoryId = categories.D2CategoryId;
    D3CategoryId = categories.D3CategoryId;
}
```
若上游 command 本來就代表這組資料,且實作 `IProductCategoriesModel`,就直接傳入:
```csharp
entity.UpdateCategories(command);
```

### DTO 映射建構式
- 從來源物件做純資料映射時,優先使用 DTO 建構式,而不是在呼叫端放一次性的 `ConvertXxx` 輔助方法.
- 這能讓建立方式更直接,也讓欄位映射與目標型別放在一起.
- 不要將 I/O 或業務決策移入建構式,也不要只為了套用此模式而取代既有共用 mapper/factory. 保留序列化/框架所需的建構式與 setter.

不要在呼叫端放 `ConvertProductBorder(entity)` 輔助方法,改將純資料映射放進 `ProductBorderCacheDto`:
```csharp
public ProductBorderCacheDto(BorderPicEntity entity)
{
    Id = entity.Id;
    Priority = entity.Priority;
}
```
呼叫端即可直接建立 DTO:
```csharp
var dto = new ProductBorderCacheDto(entity);
```

### 成員排序
依循 [Google C# Style Guide](https://google.github.io/styleguide/csharpguide.html) 的分組,順序如下:
1. 巢狀類別、enum、delegate 與 event
2. static、const 與 readonly 欄位
3. 其他欄位與屬性 (含 expression-bodied 屬性,例如 `public IUnitOfWork UnitOfWork => _context;`)
4. 建構子與解構子 (finalizer)
5. 方法

每組之內:
- 依存取層級排序: `public` → `internal` → `protected internal` → `protected` → `private`. 因此 private 方法會落在最底部.
- 同一存取層級內,`static` 成員排在實例成員之前 (StyleCop SA1204). 不採用 StyleCop 其他的排序規則;SA1201 將建構子排在屬性之前,與上方第 3 → 4 組相牴觸.
- 介面實作盡可能放在一起.

套用於新檔案與新增的成員. 只是修改某個檔案時,不重排其既有成員;重排產生的 diff 會在 review 時掩蓋真正的變更.
```csharp
public class CouponGrossMarginRepository : ICouponGrossMarginRepository
{
    private readonly SpuContext _context;                  // 2. readonly 欄位

    public IUnitOfWork UnitOfWork => _context;            // 3. 屬性

    public CouponGrossMarginRepository(SpuContext context) // 4. 建構子
    {
        _context = context;
    }

    public static bool IsValid(ICouponGrossMarginModel model) => model != null; // 5. public static

    public async Task UpsertAsync(IEnumerable<ICouponGrossMarginModel> models) { } // 5. public

    private void Apply(CouponGrossMarginEntity entity) { } // 5. private
}
```

### XML 文件
- 實體中**所有公開屬性**必須包含 `/// <summary>`.
- `<summary>` 一律寫成**三行** — 開頭標籤、內容、結尾標籤各占一行,即使描述只有一個詞也一樣.不可使用單行形式 `/// <summary>x</summary>`.
- 中文字元使用**全形**;標點符號 (`,`, `.`, `(`, `)`, `:`, `!`, `?` 等) 必須使用**半形** — 包含嵌入於中文文字中時.
```csharp
/// <summary>
/// 搜尋類型 (1: 純圖片搜尋, 2: 圖文搜尋)
/// </summary>
```
- 當成員語意**由其他型別/屬性定義**時 (例如內部 DTO / 查詢模型欄位對映實體屬性),以 `<see cref="..."/>` 引用,而非重述描述 — 來源變更時仍保持正確.
```csharp
/// <summary>
/// <see cref="MemberEntity.IsBlocked"/>
/// </summary>
public bool IsBlocked { get; set; }
```
- **例外 — API 輸入/輸出模型**: 經 Swagger 暴露的 Request / Response / ViewModel 成員**不可**使用 `<see cref="..."/>`. Swashbuckle 不會將 cref 解析進 OpenAPI schema 描述 (文字會遺失). 這類成員必須**逐字寫出描述**,列舉型欄位則**逐一列出每個值**.
```csharp
/// <summary>
/// 地址類型 (1: 宅配, 2: 店取, 3: 超取)
/// </summary>
public int AddressType { get; set; }
```

## 測試
- 斷言使用 **FluentAssertions**,而非原生 `Assert.*`.
```csharp
result.TotalCount.Should().Be(2);
failed.Success.Should().BeFalse();
result.Results.Should().ContainSingle(r => r.MemberId == 2);
```

### 該斷言什麼
- 斷言**結構化的輸出**（回傳值、事件、列舉、常數），不要斷言為人格式化的文字（trace 字串、log 行）。排版改變時，只該讓格式化器自己的測試失敗。當服務透過協作者（recorder、logger）回報原因時，換成一個只收集所收到內容的假物件，並斷言那些事件。
- 回傳值正確並不能證明「為什麼」。當多個條件都可能造成相同結果（某項目不在結果清單中、某個拒絕代碼）時，每個排除案例都要搭配一個會通過的基準案例，兩者只差那一個條件。檢查順序有意義時，讓兩個條件同時成立，並斷言是哪一個勝出。

### 名稱與弱斷言
- 測試名稱（`DisplayName`）必須精確說出內容所檢查的事——不可比內容寬（宣稱「任何來源」卻只測一種），也不可比內容窄。
- 不要寫永遠不會失敗的斷言：每個分支都會印出的字串、對 mock 永遠回傳空值的結果做 `BeNullOrEmpty`、對被測呼叫的每個引數都用 `It.IsAny`（要對重要的引數 `Verify`：id、context、時間）。
- 兩個方法的 mock 回傳同一個值，會看不出實際呼叫的是哪一個；請給它們不同的值。
- 合併重複的案例；一個行為留一個。

### 證明測試真的會失敗
- 新增或改寫測試後，暫時弄壞它所守護的正式程式碼（對調常數、拿掉條件、調換兩個檢查的順序），確認測試轉紅，再還原。在這種破壞下仍然綠燈的測試，並沒有守住那個行為。
