# C# Coding Style Standards

This document defines the strict coding standards and architectural patterns for C# development.

## Coding Standards

### Namespace & Usings
- Use **File-scoped namespace** (no curly braces for the namespace).
- Sort `using` directives **alphabetically**.

### Formatting (120 Characters Limit)
- **Method Calls & Declarations**: Keep parameters on the same line unless it exceeds 120 characters. When wrapping, indent all parameters together on the next line.
```csharp
// Correct wrapping example
public ProductRepository(
    IOptions<Settings> settings, IUnitOfWork unitOfWork, ILogger<ProductRepository> logger)
```
- **If Statements**: Use single-line guard clauses. Extract complex conditions into variables.
```csharp
if (isFirstBuyMember) return GROUP_FIRST_BUY;
```
- **Early Return / Early Continue**: Prefer inverting conditions to exit early rather than wrapping the happy path in a nested block. Apply to both methods (early `return`) and loops (early `continue`).
```csharp
// Prefer this:
if (!res.IsPass) continue;
DoWork(res);

// Over this:
if (res.IsPass)
{
    DoWork(res);
}
```

### SQL Strings
- SQL must start from the **leftmost column** (ignore C# indentation).
- **Keywords UPPERCASE**: `SELECT`, `FROM`, `WHERE`, `AND`, `OR`, `JOIN`, `LEFT JOIN`, `ON`, `IS NULL`, `LIKE`, `AS`, `UNION ALL`, etc.
- **Spaces around operators**: `r.is_delete = 0` (not `r.is_delete=0`); `x = @p` (not `x=@p`).
- `SELECT` columns on separate lines, aligned with `AS`.
- `WHERE` conditions start with `  AND` (two spaces).
```sql
SELECT psi.item_id          AS ProductId,
       p.id                 AS PromotionId
FROM promotion_scope_items psi
WHERE psi.item_type = 3
  AND psi.is_exclude = 0
```
- **No magic numbers for domain-coded columns**: when a column maps to a domain `Enumeration`, pass the value as a parameter sourced from `<Enum>.<Member>.Id` instead of a literal.
```csharp
// Prefer — parameter sourced from the domain Enumeration
parameters.Add("@homeDeliveryType", DeliveryType.HomeDelivery.Id);
// SQL:  WHERE delivery_type = @homeDeliveryType

// Avoid — magic number in SQL
// SQL:  WHERE delivery_type = 1
```

## Project Specific Patterns

### Entity Configuration (EntityConfig)
- **Minimalist**: Only use `ToTable`, `Ignore(DomainEvents)`, `HasKey`, and `Property().HasColumnName()`.
- Add new `ApplyConfiguration` calls at the **bottom** of `OnModelCreating`.
```csharp
public void Configure(EntityTypeBuilder<Entity> builder)
{
    builder.ToTable("table_name", Schema.DEFAULT);
    builder.Ignore(b => b.DomainEvents);
    builder.HasKey(c => c.Id);
    builder.Property(e => e.UserId).HasColumnName("user_id");
}
```

### Dapper Query Result Mapping
- Read Dapper query results into a **dedicated query model** (e.g., `XxxQueryModel` under `Application/Models/<Audience>/`), then map it to the response ViewModel.
- Do **NOT** `Read<>` directly into the API ViewModel — keep the DB read shape decoupled from the API contract.
```csharp
var rows = (await conn.QueryAsync<MemberReceiverQueryModel>(sql, p)).ToList();
var vo = rows.Select(x => new MemberReceiverItemVo(x)).ToList();
```

### Member Ordering
1. Constants & Fields
2. Constructors
3. Properties
4. Public Methods
5. Private Methods (at the bottom)

### XML Documentation
- **ALL public properties** in Entities MUST have `/// <summary>`.
- Chinese characters use **Full-width (全形)**; punctuation marks (`,`, `.`, `(`, `)`, `:`, `!`, `?`, etc.) MUST use **Half-width (半形)** — including when embedded in Chinese text.
```csharp
/// <summary>
/// 搜尋類型 (1: 純圖片搜尋, 2: 圖文搜尋)
/// </summary>
```
- When a member's meaning is **defined by another type/property** (e.g., an internal DTO/query-model field mirroring an entity property), reference it with `<see cref="..."/>` instead of restating the description — it stays accurate when the source changes.
```csharp
/// <summary>
/// <see cref="MemberEntity.IsBlocked"/>
/// </summary>
public bool IsBlocked { get; set; }
```
- **Exception — API input/output models**: do **NOT** use `<see cref="..."/>` on Request/Response/ViewModel members exposed via Swagger. Swashbuckle does not resolve crefs into the OpenAPI schema description (the text is lost). For these, **spell out the description literally** — and for enum-coded fields, **list every value inline**.
```csharp
/// <summary>
/// 地址類型 (1: 宅配, 2: 店取, 3: 超取)
/// </summary>
public int AddressType { get; set; }
```

## API Design Standards
- Use **ONLY GET and POST**.
- **GET**: For queries. **POST**: For Create, Update, Delete.

## Testing
- Use **FluentAssertions** for assertions, not raw `Assert.*`.
```csharp
result.TotalCount.Should().Be(2);
failed.Success.Should().BeFalse();
result.Results.Should().ContainSingle(r => r.MemberId == 2);
```
