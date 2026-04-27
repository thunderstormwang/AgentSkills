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

### SQL Strings
- SQL must start from the **leftmost column** (ignore C# indentation).
- `SELECT` columns on separate lines, aligned with `AS`.
- `WHERE` conditions start with `  AND` (two spaces).
```sql
SELECT psi.item_id          AS ProductId,
       p.id                 AS PromotionId
FROM promotion_scope_items psi
WHERE psi.item_type = 3
  AND psi.is_exclude = 0
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

### Member Ordering
1. Constants & Fields
2. Constructors
3. Properties
4. Public Methods
5. Private Methods (at the bottom)

### XML Documentation
- **ALL public properties** in Entities MUST have `/// <summary>`.
- Use **Full-width (全形)** for Chinese text, **Half-width (半形)** for everything else.
```csharp
/// <summary>
/// 搜尋類型 (1: 純圖片搜尋, 2: 圖文搜尋)
/// </summary>
```

## API Design Standards
- Use **ONLY GET and POST**.
- **GET**: For queries. **POST**: For Create, Update, Delete.
