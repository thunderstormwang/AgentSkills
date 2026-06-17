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

### 成員排序
1. 常數與欄位
2. 建構子
3. 屬性
4. 公開方法
5. 私有方法 (置於底部)

### XML 文件
- 實體中**所有公開屬性**必須包含 `/// <summary>`.
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

## API 設計標準
- **只使用 GET 和 POST**.
- **GET**: 用於查詢. **POST**: 用於新增、更新、刪除.

## 測試
- 斷言使用 **FluentAssertions**,而非原生 `Assert.*`.
```csharp
result.TotalCount.Should().Be(2);
failed.Success.Should().BeFalse();
result.Results.Should().ContainSingle(r => r.MemberId == 2);
```
