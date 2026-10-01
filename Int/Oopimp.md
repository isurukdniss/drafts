Yes. The important thing is to see **why the bad version violates SOLID**, not just see the good version.

Here is a deliberately bad but realistic implementation.

### Bad `OrderService`

```csharp
public class OrderService
{
    public void CreateOrder(
        int customerId,
        List<OrderItem> items)
    {
        // ==========================================
        // 1. VALIDATION
        // ==========================================

        if (customerId <= 0)
        {
            throw new ArgumentException(
                "Invalid customer ID.");
        }

        if (items == null || items.Count == 0)
        {
            throw new ArgumentException(
                "Order must contain at least one item.");
        }

        foreach (var item in items)
        {
            if (item.ProductId <= 0)
            {
                throw new ArgumentException(
                    "Invalid product ID.");
            }

            if (item.Quantity <= 0)
            {
                throw new ArgumentException(
                    "Quantity must be greater than zero.");
            }

            if (item.Price < 0)
            {
                throw new ArgumentException(
                    "Price cannot be negative.");
            }
        }


        // ==========================================
        // 2. CALCULATE PRICE
        // ==========================================

        decimal subtotal = 0;

        foreach (var item in items)
        {
            subtotal += item.Price * item.Quantity;
        }

        // 10% discount for orders over $1,000
        decimal discount = 0;

        if (subtotal > 1000)
        {
            discount = subtotal * 0.10m;
        }

        decimal tax = (subtotal - discount) * 0.08m;

        decimal total = subtotal - discount + tax;


        // ==========================================
        // 3. SAVE TO SQL SERVER
        // ==========================================

        using var connection = new SqlConnection(
            "Server=localhost;" +
            "Database=Orders;" +
            "Trusted_Connection=True;");

        connection.Open();

        using var transaction =
            connection.BeginTransaction();

        try
        {
            var orderCommand = new SqlCommand(
                """
                INSERT INTO Orders
                (
                    CustomerId,
                    Subtotal,
                    Discount,
                    Tax,
                    Total
                )
                VALUES
                (
                    @CustomerId,
                    @Subtotal,
                    @Discount,
                    @Tax,
                    @Total
                );

                SELECT SCOPE_IDENTITY();
                """,
                connection,
                transaction);

            orderCommand.Parameters.AddWithValue(
                "@CustomerId",
                customerId);

            orderCommand.Parameters.AddWithValue(
                "@Subtotal",
                subtotal);

            orderCommand.Parameters.AddWithValue(
                "@Discount",
                discount);

            orderCommand.Parameters.AddWithValue(
                "@Tax",
                tax);

            orderCommand.Parameters.AddWithValue(
                "@Total",
                total);

            var orderId =
                Convert.ToInt32(
                    orderCommand.ExecuteScalar());


            // Save order items

            foreach (var item in items)
            {
                var itemCommand = new SqlCommand(
                    """
                    INSERT INTO OrderItems
                    (
                        OrderId,
                        ProductId,
                        Price,
                        Quantity
                    )
                    VALUES
                    (
                        @OrderId,
                        @ProductId,
                        @Price,
                        @Quantity
                    )
                    """,
                    connection,
                    transaction);

                itemCommand.Parameters.AddWithValue(
                    "@OrderId",
                    orderId);

                itemCommand.Parameters.AddWithValue(
                    "@ProductId",
                    item.ProductId);

                itemCommand.Parameters.AddWithValue(
                    "@Price",
                    item.Price);

                itemCommand.Parameters.AddWithValue(
                    "@Quantity",
                    item.Quantity);

                itemCommand.ExecuteNonQuery();
            }

            transaction.Commit();


            // ==========================================
            // 4. SEND EMAIL
            // ==========================================

            using var smtp = new SmtpClient("smtp.company.com");

            var email = new MailMessage(
                "orders@company.com",
                GetCustomerEmail(customerId));

            email.Subject = "Order Created";

            email.Body =
                $"Your order #{orderId} " +
                $"was created successfully." +
                $"\nTotal: {total:C}";

            smtp.Send(email);


            // ==========================================
            // 5. GENERATE PDF
            // ==========================================

            var pdf = new PdfDocument();

            pdf.AddText($"Order #{orderId}");
            pdf.AddText($"Customer: {customerId}");
            pdf.AddText($"Subtotal: {subtotal:C}");
            pdf.AddText($"Discount: {discount:C}");
            pdf.AddText($"Tax: {tax:C}");
            pdf.AddText($"Total: {total:C}");

            pdf.Save(
                $"C:\\Orders\\Order-{orderId}.pdf");
        }
        catch
        {
            transaction.Rollback();
            throw;
        }
    }


    // More responsibility inside the same class
    private string GetCustomerEmail(int customerId)
    {
        using var connection = new SqlConnection(
            "Server=localhost;" +
            "Database=Orders;" +
            "Trusted_Connection=True;");

        connection.Open();

        using var command = new SqlCommand(
            "SELECT Email FROM Customers " +
            "WHERE Id = @Id",
            connection);

        command.Parameters.AddWithValue(
            "@Id",
            customerId);

        return command.ExecuteScalar()?.ToString()
               ?? throw new Exception(
                   "Customer email not found.");
    }
}
```

Assume these are external/library types:

```csharp
public class OrderItem
{
    public int ProductId { get; set; }
    public decimal Price { get; set; }
    public int Quantity { get; set; }
}
```

---

# Why is this bad?

Look at everything this one class knows about:

```text
                       OrderService
                            │
       ┌────────────────────┼────────────────────┐
       ↓                    ↓                    ↓
   Validation          Price calculation      SQL Server
       │                    │                    │
       ↓                    ↓                    ↓
   Email sending        PDF generation       Connection
                                             Transaction
```

It has **far too many responsibilities**.

---

# 1. SRP violation

The class has multiple reasons to change.

```text
OrderService
│
├── Validation
├── Pricing
├── Database persistence
├── Email
├── PDF
└── Customer lookup
```

Imagine six different changes:

```text
Business changes validation
        ↓
OrderService changes

Pricing rules change
        ↓
OrderService changes

Database changes
        ↓
OrderService changes

Email provider changes
        ↓
OrderService changes

PDF library changes
        ↓
OrderService changes

Customer lookup changes
        ↓
OrderService changes
```

That's a classic **Single Responsibility Principle violation**.

---

# 2. OCP violation

Look at:

```csharp
if (subtotal > 1000)
{
    discount = subtotal * 0.10m;
}
```

Now the business says:

> Gold customers get 20%.

You modify the class:

```csharp
if (customer.Type == "Gold")
{
    discount = subtotal * 0.20m;
}
else if (subtotal > 1000)
{
    discount = subtotal * 0.10m;
}
```

Then:

> VIP customers get 30%.

Modify it again.

Then:

> Black Friday gets 40%.

Modify it again.

The class keeps growing.

A better design would use:

```text
IDiscountStrategy
       │
       ├── RegularDiscount
       ├── GoldDiscount
       ├── VipDiscount
       └── BlackFridayDiscount
```

Then new behavior can be added without changing `OrderService`.

---

# 3. DIP violation

This is particularly obvious:

```csharp
using var connection = new SqlConnection(...);
```

The high-level business class directly depends on:

```text
OrderService
      ↓
SqlConnection
```

And:

```csharp
using var smtp =
    new SmtpClient("smtp.company.com");
```

Again:

```text
OrderService
      ↓
SmtpClient
```

And:

```csharp
var pdf = new PdfDocument();
```

Again:

```text
OrderService
      ↓
PdfDocument
```

The business logic is tightly coupled to infrastructure.

---

# 4. ISP problem

Imagine this class eventually exposes:

```csharp
public interface IOrderService
{
    void CreateOrder();
    void ValidateOrder();
    void CalculatePrice();
    void SaveOrder();
    void SendEmail();
    void GeneratePdf();
    void ExportExcel();
    void SendSms();
}
```

Now consumers may depend on methods they don't need.

This is exactly the kind of **fat interface** that ISP tries to prevent.

Instead, use focused abstractions:

```csharp
IOrderRepository
IPriceCalculator
IEmailService
IPdfGenerator
```

---

# 5. LSP

The bad example doesn't necessarily have a direct LSP violation because it doesn't use inheritance.

That's important.

**SOLID principles don't mean every class must violate or demonstrate every principle.**

LSP becomes relevant when we introduce inheritance.

For example, this could be problematic:

```csharp
public class OrderRepository
{
    public virtual void Save(Order order)
    {
        // Save
    }
}

public class ReadOnlyOrderRepository
    : OrderRepository
{
    public override void Save(Order order)
    {
        throw new NotSupportedException();
    }
}
```

Now:

```csharp
OrderRepository repository =
    new ReadOnlyOrderRepository();

repository.Save(order);
```

The caller expects `Save()` to work, but the subtype throws.

That's an LSP problem.

---

# The Refactoring

We can gradually transform the bad class:

### Before

```text
OrderService
│
├── Validate
├── Calculate price
├── SQL
├── Email
├── PDF
└── Customer lookup
```

### After

```text
                   OrderService
                        │
        ┌───────────────┼────────────────┐
        ↓               ↓                ↓
IOrderValidator  IPriceCalculator  IOrderRepository
                                         │
                                         ↓
                                  OrderRepository
                                         │
                                         ↓
                                      EF Core


OrderService
     │
     ├──────────────→ IEmailService
     │
     └──────────────→ IPdfGenerator
```

Now each class has a focused responsibility.

---

# The key transformation

### ❌ Bad

```csharp
public class OrderService
{
    // Validate
    // Calculate
    // SQL
    // Email
    // PDF
}
```

### ✅ Good

```csharp
public class OrderService
{
    private readonly IOrderValidator _validator;
    private readonly IPriceCalculator _calculator;
    private readonly IOrderRepository _repository;
    private readonly IEmailService _email;
    private readonly IPdfGenerator _pdf;

    public OrderService(
        IOrderValidator validator,
        IPriceCalculator calculator,
        IOrderRepository repository,
        IEmailService email,
        IPdfGenerator pdf)
    {
        _validator = validator;
        _calculator = calculator;
        _repository = repository;
        _email = email;
        _pdf = pdf;
    }

    public async Task CreateOrderAsync(
        CreateOrderRequest request)
    {
        _validator.Validate(request);

        var order = _calculator.Calculate(request);

        await _repository.SaveAsync(order);

        await _email.SendAsync(order);

        await _pdf.GenerateAsync(order);
    }
}
```

Now `OrderService` is primarily an **orchestrator**.

It says:

```text
Validate
   ↓
Calculate
   ↓
Save
   ↓
Notify
   ↓
Generate document
```

It doesn't know **how** those operations are performed.

That's the major SOLID transformation:

```text
BAD:
High-level business logic
        ↓
Concrete implementations


GOOD:
High-level business logic
        ↓
      Interfaces
        ↑
Concrete implementations
```

And this is exactly the type of refactoring you should be able to explain in a **Senior .NET interview**.

_____ 

Yes. Let's implement the **OrderService** example as a realistic .NET 8 implementation, applying **all five SOLID principles**, while keeping the architecture interview-friendly.

## 1. Domain model

```csharp
public class Order
{
    public int Id { get; private set; }
    public List<OrderItem> Items { get; private set; } = [];

    public decimal Total => Items.Sum(x => x.Price * x.Quantity);

    public void AddItem(int productId, decimal price, int quantity)
    {
        if (quantity <= 0)
            throw new ArgumentException("Quantity must be greater than zero.");

        if (price < 0)
            throw new ArgumentException("Price cannot be negative.");

        Items.Add(new OrderItem(productId, price, quantity));
    }
}

public class OrderItem
{
    public int ProductId { get; }
    public decimal Price { get; }
    public int Quantity { get; }

    public OrderItem(int productId, decimal price, int quantity)
    {
        ProductId = productId;
        Price = price;
        Quantity = quantity;
    }
}
```

### Encapsulation

Notice:

```csharp
public int Id { get; private set; }
public List<OrderItem> Items { get; private set; } = [];
```

External code can't simply do:

```csharp
order.Items = null;
```

Business behavior is exposed through:

```csharp
order.AddItem(...);
```

---

# 2. Repository abstraction

Instead of making `OrderService` depend directly on EF Core:

```csharp
public interface IOrderRepository
{
    Task<Order?> GetAsync(int id, CancellationToken cancellationToken);
    Task AddAsync(Order order, CancellationToken cancellationToken);
    Task SaveChangesAsync(CancellationToken cancellationToken);
}
```

This is the **abstraction**.

---

# 3. EF Core implementation

```csharp
public class OrderRepository : IOrderRepository
{
    private readonly AppDbContext _db;

    public OrderRepository(AppDbContext db)
    {
        _db = db;
    }

    public async Task<Order?> GetAsync(
        int id,
        CancellationToken cancellationToken)
    {
        return await _db.Orders
            .Include(x => x.Items)
            .FirstOrDefaultAsync(
                x => x.Id == id,
                cancellationToken);
    }

    public async Task AddAsync(
        Order order,
        CancellationToken cancellationToken)
    {
        await _db.Orders.AddAsync(order, cancellationToken);
    }

    public Task SaveChangesAsync(
        CancellationToken cancellationToken)
    {
        return _db.SaveChangesAsync(cancellationToken);
    }
}
```

Now the application layer doesn't care whether the database is:

```text
SQL Server
PostgreSQL
Oracle
MySQL
```

---

# 4. Separate order calculation

Instead of putting pricing logic inside `OrderService`:

```csharp
public interface IOrderCalculator
{
    decimal CalculateTotal(Order order);
}
```

Implementation:

```csharp
public class OrderCalculator : IOrderCalculator
{
    public decimal CalculateTotal(Order order)
    {
        return order.Items.Sum(
            x => x.Price * x.Quantity);
    }
}
```

Later we could introduce:

```text
IOrderCalculator
       │
       ├── StandardOrderCalculator
       ├── DiscountedOrderCalculator
       └── PromotionalOrderCalculator
```

This demonstrates **OCP**.

---

# 5. Email abstraction

```csharp
public interface IEmailService
{
    Task SendOrderCreatedAsync(
        Order order,
        CancellationToken cancellationToken);
}
```

Implementation:

```csharp
public class EmailService : IEmailService
{
    public async Task SendOrderCreatedAsync(
        Order order,
        CancellationToken cancellationToken)
    {
        // Send email using SMTP,
        // Amazon SES, SendGrid, etc.

        await Task.CompletedTask;
    }
}
```

The `OrderService` doesn't know how email is sent.

---

# 6. OrderService

Now the important part:

```csharp
public class OrderService
{
    private readonly IOrderRepository _repository;
    private readonly IOrderCalculator _calculator;
    private readonly IEmailService _emailService;

    public OrderService(
        IOrderRepository repository,
        IOrderCalculator calculator,
        IEmailService emailService)
    {
        _repository = repository;
        _calculator = calculator;
        _emailService = emailService;
    }

    public async Task<int> CreateOrderAsync(
        CreateOrderRequest request,
        CancellationToken cancellationToken)
    {
        var order = new Order();

        foreach (var item in request.Items)
        {
            order.AddItem(
                item.ProductId,
                item.Price,
                item.Quantity);
        }

        var total = _calculator.CalculateTotal(order);

        await _repository.AddAsync(
            order,
            cancellationToken);

        await _repository.SaveChangesAsync(
            cancellationToken);

        await _emailService.SendOrderCreatedAsync(
            order,
            cancellationToken);

        return order.Id;
    }
}
```

Notice what `OrderService` **doesn't** know about:

```text
❌ EF Core
❌ SQL
❌ SMTP
❌ Amazon SES
❌ Database connection
❌ SQL queries
```

It only knows:

```text
IOrderRepository
IOrderCalculator
IEmailService
```

---

# 7. Request DTO

```csharp
public record CreateOrderRequest(
    List<CreateOrderItemRequest> Items);

public record CreateOrderItemRequest(
    int ProductId,
    decimal Price,
    int Quantity);
```

---

# 8. API Controller

```csharp
[ApiController]
[Route("api/orders")]
public class OrdersController : ControllerBase
{
    private readonly OrderService _orderService;

    public OrdersController(OrderService orderService)
    {
        _orderService = orderService;
    }

    [HttpPost]
    public async Task<IActionResult> Create(
        CreateOrderRequest request,
        CancellationToken cancellationToken)
    {
        var orderId = await _orderService.CreateOrderAsync(
            request,
            cancellationToken);

        return Created(
            $"/api/orders/{orderId}",
            new { orderId });
    }
}
```

Architecture:

```text
HTTP Request
     │
     ↓
OrdersController
     │
     ↓
OrderService
     │
     ├──────────────→ IOrderCalculator
     │
     ├──────────────→ IOrderRepository
     │                       │
     │                       ↓
     │                    EF Core
     │                       │
     │                       ↓
     │                    Database
     │
     └──────────────→ IEmailService
```

---

# 9. Dependency Injection

In `Program.cs`:

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddScoped<IOrderRepository, OrderRepository>();
builder.Services.AddScoped<IOrderCalculator, OrderCalculator>();
builder.Services.AddScoped<IEmailService, EmailService>();

builder.Services.AddScoped<OrderService>();

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("Default"));
});

builder.Services.AddControllers();

var app = builder.Build();

app.MapControllers();

app.Run();
```

Now ASP.NET Core constructs:

```text
OrderService
     │
     ├── IOrderRepository → OrderRepository
     ├── IOrderCalculator → OrderCalculator
     └── IEmailService    → EmailService
```

This is **Dependency Injection**.

---

# 10. Where is each SOLID principle?

### S — Single Responsibility

Each component has one primary responsibility:

```text
Order
    → Order business rules

OrderService
    → Order application workflow

OrderRepository
    → Persistence

OrderCalculator
    → Price calculation

EmailService
    → Email delivery

OrdersController
    → HTTP handling
```

---

### O — Open/Closed

Suppose you introduce a VIP pricing strategy.

```csharp
public class VipOrderCalculator : IOrderCalculator
{
    public decimal CalculateTotal(Order order)
    {
        var total = order.Items.Sum(
            x => x.Price * x.Quantity);

        return total * 0.90m;
    }
}
```

You didn't modify:

```text
OrderService
Order
OrderRepository
EmailService
```

You **extended** the system.

---

### L — Liskov Substitution

Both:

```text
OrderCalculator
VipOrderCalculator
```

implement:

```text
IOrderCalculator
```

Therefore:

```csharp
IOrderCalculator calculator =
    new VipOrderCalculator();
```

`OrderService` can use it without knowing the concrete implementation.

The implementation must still honor the contract of `IOrderCalculator`.

---

### I — Interface Segregation

Instead of:

```csharp
public interface IOrderService
{
    CreateOrder();
    DeleteOrder();
    SendEmail();
    GeneratePdf();
    ExportToExcel();
    SaveToDatabase();
}
```

we have focused interfaces:

```text
IOrderRepository
IOrderCalculator
IEmailService
```

Each consumer gets only what it needs.

---

### D — Dependency Inversion

This is the most important one in this example.

Bad:

```csharp
OrderService
     ↓
SqlOrderRepository
```

Good:

```text
OrderService
     ↓
IOrderRepository
     ↑
SqlOrderRepository
```

The high-level business logic doesn't depend directly on the low-level database implementation.

---

# 11. Unit Testing Becomes Easy

Because `OrderService` depends on interfaces, we can mock them.

Using Moq:

```csharp
[Fact]
public async Task CreateOrder_Should_Save_Order()
{
    // Arrange
    var repository = new Mock<IOrderRepository>();
    var calculator = new Mock<IOrderCalculator>();
    var emailService = new Mock<IEmailService>();

    calculator
        .Setup(x => x.CalculateTotal(It.IsAny<Order>()))
        .Returns(100);

    var service = new OrderService(
        repository.Object,
        calculator.Object,
        emailService.Object);

    var request = new CreateOrderRequest(
    [
        new CreateOrderItemRequest(
            ProductId: 1,
            Price: 100,
            Quantity: 1)
    ]);

    // Act
    await service.CreateOrderAsync(
        request,
        CancellationToken.None);

    // Assert
    repository.Verify(
        x => x.AddAsync(
            It.IsAny<Order>(),
            It.IsAny<CancellationToken>()),
        Times.Once);
}
```

You can test `OrderService` without:

```text
❌ SQL Server
❌ Database
❌ SMTP server
❌ AWS
```

That's one of the biggest practical benefits of **DIP + DI**.

---

# 12. The Key Interview Diagram

Memorize this:

```text
                 ┌──────────────────┐
                 │    Controller    │
                 └────────┬─────────┘
                          ↓
                 ┌──────────────────┐
                 │   OrderService   │
                 └────────┬─────────┘
                          │
             ┌────────────┼─────────────┐
             ↓            ↓             ↓
      IOrderRepository  ICalculator  IEmailService
             ↑            ↑             ↑
             │            │             │
      OrderRepository  Calculator   EmailService
             │
             ↓
          EF Core
             │
             ↓
          Database
```

And the dependency direction is:

```text
          HIGH LEVEL
              │
              ↓
        OrderService
              │
              ↓
         ABSTRACTIONS
              │
       ┌──────┼──────┐
       ↓      ↓      ↓
   Repository Calculator Email
       ↑
       │
   LOW LEVEL
       │
       ↓
     EF Core
       ↓
    Database
```

**The interview takeaway:** SOLID isn't five independent rules you memorize. In a real .NET application, they work together to produce **high cohesion, low coupling, replaceable components, testability, and maintainable architecture**.
