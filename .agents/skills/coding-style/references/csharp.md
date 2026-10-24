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

### No Magic Numbers
- Do not compare, assign, or pass a bare literal for a domain-coded value (`!= 0`, `== 1`, `Type = 3`). Use the named member: `<Enumeration>.<Member>.Id` for an `Enumeration` class, or `(int)<Enum>.<Member>` for a C# `enum` when the field is stored as `int`.
- If no named type exists for the codes yet, add one with a member for every known value, including the "none" value, rather than keeping the literal with a comment.
- A check meaning "any non-default value" compares against the named default member; it does not enumerate every other member.
```csharp
// Prefer
if (coupon.MarginPassType != (int)MarginPassType.None) return false;
.Where(x => x.MemberUseType == PromotionMemberUseType.AllMember.Id)

// Avoid
if (coupon.MarginPassType != 0) return false;
.Where(x => x.MemberUseType == 0)
```
- The same rule applies to SQL strings; see below.

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

### Caller-Focused Interfaces
- Expose only the capabilities callers need, not every method on the implementation class. Keep internal steps private.
- This prevents callers from bypassing the complete workflow and keeps implementation details out of the public contract.

Avoid exposing the steps used to load and refill a cache:
```csharp
public interface ISettingCache
{
    Task<SettingDto> GetAsync();
    Task<SettingDto> LoadFromDatabaseAsync();
    Task WriteCacheAsync(SettingDto setting);
}
```
Prefer a contract for the caller's actual operation; keep loading and writing private in the implementation:
```csharp
public interface ISettingCache
{
    Task<SettingDto> GetAsync();
}
```

### Empty Interfaces
- Do not introduce or retain empty interfaces without an actual role in marker-based behavior, generic constraints, registration, or discovery.
- An unused inheritance layer adds investigation and maintenance work without providing capabilities or constraints.

If `ICacheRepository<T>` has no such role, remove the empty parent rather than inheriting it just for classification:
```csharp
// Avoid an unused parent.
public interface ICacheRepository<T> { }
public interface IProductCache : ICacheRepository<ProductDto>
{
    Task<ProductDto> GetAsync(int productId);
}
```
```csharp
// Prefer the actual contract.
public interface IProductCache
{
    Task<ProductDto> GetAsync(int productId);
}
```

### Logging-Only Context
- Prefer the existing logger and local variables over a mutable context passed through methods solely to track the current logging stage.
- Such a context requires updates at every step. Cleanup can overwrite the stage and make a log describe cleanup rather than the original failure.
- Retain contexts that genuinely manage shared state or lifetimes. Preserve necessary locking, cleanup, and exception handling.

Avoid extra state maintained only for diagnostics:
```csharp
context.Stage = "ReadCache";
context.Key = key;
var value = await ReadAsync(key);

context.Stage = "WriteCache";
await WriteAsync(key, value);
```
Prefer logging the full exception with a useful identifier:
```csharp
catch (Exception exception)
{
    _logger.LogWarning(exception, "Failed to get product cache. ProductId: {ProductId}", productId);
    throw;
}
```
The rethrow illustrates a propagating exception contract; preserve the method's established fallback or propagation behavior. Add targeted diagnostic detail when needed, not a tracking framework by default.

### Parameter Models Across Call Chains
- When many parameters belong to a cohesive group of business data, look for an existing model/interface pattern before adding a new one.
- Update constructors, update methods, and upstream callers consistently. Packaging arguments only at the bottom leaves long argument lists and positional mistakes upstream.
- Do not bundle unrelated parameters merely to shorten a signature.

Instead of repeatedly passing individual category IDs:
```csharp
entity.UpdateCategories(command.D1CategoryId, command.D2CategoryId, command.D3CategoryId);
```
Reuse the existing category contract:
```csharp
public void UpdateCategories(IProductCategoriesModel categories)
{
    D1CategoryId = categories.D1CategoryId;
    D2CategoryId = categories.D2CategoryId;
    D3CategoryId = categories.D3CategoryId;
}
```
When the upstream command already represents this data and implements `IProductCategoriesModel`, pass it directly:
```csharp
entity.UpdateCategories(command);
```

### DTO Mapping Constructors
- For pure mapping from a source object, prefer a DTO constructor over a one-off `ConvertXxx` helper on the caller.
- This keeps creation direct and field mapping with the destination type.
- Do not move I/O or business decisions into constructors, or replace an established shared mapper/factory merely to follow this pattern. Preserve constructors and setters required by serialization/frameworks.

Instead of a caller-local `ConvertProductBorder(entity)` helper, put the pure mapping in `ProductBorderCacheDto`:
```csharp
public ProductBorderCacheDto(BorderPicEntity entity)
{
    Id = entity.Id;
    Priority = entity.Priority;
}
```
The caller then constructs the DTO directly:
```csharp
var dto = new ProductBorderCacheDto(entity);
```

### Member Ordering
Follow the [Google C# Style Guide](https://google.github.io/styleguide/csharpguide.html) groups, in this order:
1. Nested classes, enums, delegates, and events
2. Static, const, and readonly fields
3. Other fields and properties (including expression-bodied properties such as `public IUnitOfWork UnitOfWork => _context;`)
4. Constructors and finalizers
5. Methods

Within each group:
- Order by access level: `public` → `internal` → `protected internal` → `protected` → `private`. Private methods therefore end up at the bottom.
- Within the same access level, place `static` members before instance members (StyleCop SA1204). Do not adopt StyleCop's other ordering rules; SA1201 puts constructors before properties, which contradicts group 3 → 4 above.
- Keep interface implementations together where possible.

Apply this to new files and newly added members. Do not reorder existing members of a file you are only modifying; the reordering diff obscures the real change in review.
```csharp
public class CouponGrossMarginRepository : ICouponGrossMarginRepository
{
    private readonly SpuContext _context;                  // 2. readonly field

    public IUnitOfWork UnitOfWork => _context;            // 3. property

    public CouponGrossMarginRepository(SpuContext context) // 4. constructor
    {
        _context = context;
    }

    public static bool IsValid(ICouponGrossMarginModel model) => model != null; // 5. public static

    public async Task UpsertAsync(IEnumerable<ICouponGrossMarginModel> models) { } // 5. public

    private void Apply(CouponGrossMarginEntity entity) { } // 5. private
}
```

### XML Documentation
- **ALL public properties** in Entities MUST have `/// <summary>`.
- Always write `<summary>` as **three lines** — opening tag, text, closing tag — even when the description is a single word. Never use the one-line form `/// <summary>x</summary>`.
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

## Testing
- Use **FluentAssertions** for assertions, not raw `Assert.*`.
```csharp
result.TotalCount.Should().Be(2);
failed.Success.Should().BeFalse();
result.Results.Should().ContainSingle(r => r.MemberId == 2);
```

### What to assert
- Assert **structured output** (return values, events, enums, constants), not text formatted for people (trace strings, log lines). A change of layout must break only the formatter's own tests. When a service reports its reasons through a collaborator (a recorder, a logger), substitute a fake that just collects what it receives and assert those events.
- A correct return value does not prove *why*. When several conditions can produce the same outcome (an item missing from a result list, a rejection code), pair every exclusion case with a baseline that passes and differs in only that one condition. Where the order of checks matters, make two conditions true at once and assert which one wins.

### Names and weak assertions
- A test name (`DisplayName`) must say exactly what the body checks — no wider (claims "any source" but exercises one) and no narrower.
- No assertion that cannot fail: a string every branch prints, `BeNullOrEmpty` on a result a mock always returns empty, `It.IsAny` for every argument of the call under test (`Verify` the ones that matter: id, context, time).
- Mocks of two methods that return the same value hide which one was called; give them different values.
- Merge duplicate cases; keep one per behavior.

### Prove the test can fail
- After adding or rewriting a test, temporarily break the production code it guards (swap a constant, drop a condition, reorder two checks) and confirm the test goes red, then revert. A test that stays green under the mutation does not guard that behavior.
